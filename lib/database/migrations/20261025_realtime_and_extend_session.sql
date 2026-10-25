-- ============================================================================
-- MIGRASI BASIS DATA: REALTIME REPLICATION & DYNAMIC EXTEND PARKING SESSION
-- Path: lib/database/migrations/20261025_realtime_and_extend_session.sql
-- ============================================================================

-- 1. Penambahan Kolom Extended Waktu Parkir
ALTER TABLE public.bookings 
    ADD COLUMN IF NOT EXISTS extended_count INT NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS extended_minutes INT NOT NULL DEFAULT 0;

ALTER TABLE public.parking_sessions 
    ADD COLUMN IF NOT EXISTS extended_count INT NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS extended_minutes INT NOT NULL DEFAULT 0;

-- 2. Stored Procedure Extend Sesi Parkir / Booking Terintegrasi
CREATE OR REPLACE FUNCTION public.extend_parking_session(
    p_session_id text,
    p_additional_minutes int,
    p_cost numeric
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_session RECORD;
  v_booking RECORD;
  v_current_end timestamptz;
  v_new_end timestamptz;
  v_new_duration_hours int;
  v_booking_id uuid;
  v_actual_session_id uuid;
  v_additional_hours int := CEIL(p_additional_minutes::numeric / 60.0);
BEGIN
  -- 1. Cari di parking_sessions dulu
  SELECT * INTO v_session
  FROM parking_sessions
  WHERE id::text = p_session_id OR session_code = p_session_id
  LIMIT 1;

  IF FOUND THEN
    v_actual_session_id := v_session.id;
    v_booking_id := v_session.booking_id;
    
    IF v_session.expected_check_out_time IS NOT NULL AND v_session.expected_check_out_time > NOW() THEN
      v_current_end := v_session.expected_check_out_time;
    ELSE
      v_current_end := NOW();
    END IF;
    
    v_new_end := v_current_end + (p_additional_minutes || ' minutes')::interval;

    UPDATE parking_sessions
    SET expected_check_out_time = v_new_end,
        total_fee = COALESCE(total_fee, 0) + p_cost,
        extended_count = COALESCE(extended_count, 0) + 1,
        extended_minutes = COALESCE(extended_minutes, 0) + p_additional_minutes,
        updated_at = NOW()
    WHERE id = v_actual_session_id;

    IF v_booking_id IS NOT NULL THEN
      UPDATE bookings
      SET end_time = v_new_end,
          duration_hours = COALESCE(duration_hours, 1) + v_additional_hours,
          total_price = COALESCE(total_price, 0) + p_cost,
          extended_count = COALESCE(extended_count, 0) + 1,
          extended_minutes = COALESCE(extended_minutes, 0) + p_additional_minutes,
          updated_at = NOW()
      WHERE id = v_booking_id;
    END IF;

    RETURN jsonb_build_object(
      'success', true,
      'type', 'session',
      'session_id', v_actual_session_id,
      'booking_id', v_booking_id,
      'new_end_time', v_new_end,
      'additional_minutes', p_additional_minutes,
      'cost', p_cost
    );
  END IF;

  -- 2. Jika tidak ditemukan di parking_sessions, cari di bookings
  SELECT * INTO v_booking
  FROM bookings
  WHERE id::text = p_session_id OR booking_code = p_session_id
  LIMIT 1;

  IF FOUND THEN
    IF v_booking.end_time IS NOT NULL AND v_booking.end_time > NOW() THEN
      v_current_end := v_booking.end_time;
    ELSE
      v_current_end := NOW();
    END IF;
    
    v_new_end := v_current_end + (p_additional_minutes || ' minutes')::interval;
    v_new_duration_hours := COALESCE(v_booking.duration_hours, 1) + v_additional_hours;

    UPDATE bookings
    SET end_time = v_new_end,
        duration_hours = v_new_duration_hours,
        total_price = COALESCE(total_price, 0) + p_cost,
        extended_count = COALESCE(extended_count, 0) + 1,
        extended_minutes = COALESCE(extended_minutes, 0) + p_additional_minutes,
        updated_at = NOW()
    WHERE id = v_booking.id;

    RETURN jsonb_build_object(
      'success', true,
      'type', 'booking',
      'booking_id', v_booking.id,
      'new_end_time', v_new_end,
      'additional_minutes', p_additional_minutes,
      'duration_hours', v_new_duration_hours,
      'cost', p_cost
    );
  END IF;

  RETURN jsonb_build_object(
    'success', false,
    'message', 'Sesi parkir atau booking tidak ditemukan.'
  );
END;
$$;

-- 3. Stored Procedure Pembersihan Booking Kedaluwarsa & Pembebasan Slot
CREATE OR REPLACE FUNCTION public.auto_process_expired_bookings_and_sessions()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_cancelled_bookings INT := 0;
    v_completed_bookings INT := 0;
    v_completed_sessions INT := 0;
    v_released_slots INT := 0;
BEGIN
    BEGIN
        PERFORM public.evaluate_all_membership_tiers_monthly();
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;

    -- Auto-cancel booking unpaid > 179 detik
    WITH cancelled_rows AS (
        UPDATE public.bookings
        SET booking_status = 'cancelled',
            cancel_reason = 'Auto-cancel: Batas waktu pembayaran 2 menit 59 detik telah habis',
            updated_at = NOW()
        WHERE payment_status = 'unpaid'
          AND booking_status NOT IN ('cancelled', 'completed', 'expired')
          AND created_at < (NOW() - INTERVAL '179 seconds')
        RETURNING id
    )
    SELECT COUNT(*) INTO v_cancelled_bookings FROM cancelled_rows;

    -- Auto-complete booking berbayar yang end_time lewat
    WITH completed_b_rows AS (
        UPDATE public.bookings
        SET booking_status = 'completed',
            updated_at = NOW()
        WHERE payment_status = 'paid'
          AND booking_status IN ('upcoming', 'active')
          AND end_time <= NOW()
        RETURNING id
    )
    SELECT COUNT(*) INTO v_completed_bookings FROM completed_b_rows;

    -- Auto-complete sesi parkir aktif yang expected_check_out_time lewat
    WITH completed_s_rows AS (
        UPDATE public.parking_sessions
        SET status = 'completed',
            check_out_time = COALESCE(check_out_time, NOW()),
            updated_at = NOW()
        WHERE status = 'active'
          AND expected_check_out_time <= NOW()
        RETURNING id
    )
    SELECT COUNT(*) INTO v_completed_sessions FROM completed_s_rows;

    -- Bebaskan slot menjadi available
    WITH freed_slots AS (
        UPDATE public.parking_slots ps
        SET status = 'available',
            occupied_since = NULL,
            current_plate_number = NULL,
            updated_at = NOW()
        WHERE ps.status IN ('occupied', 'reserved')
          AND NOT EXISTS (
              SELECT 1 FROM public.parking_sessions sess
              WHERE sess.slot_id = ps.id
                AND sess.status = 'active'
          )
          AND NOT EXISTS (
              SELECT 1 FROM public.bookings bk
              WHERE bk.slot_id = ps.id
                AND bk.booking_status IN ('upcoming', 'active')
                AND bk.payment_status = 'paid'
                AND bk.end_time > NOW()
          )
        RETURNING ps.id
    )
    SELECT COUNT(*) INTO v_released_slots FROM freed_slots;

    RETURN json_build_object(
        'success', true,
        'cancelled_bookings', v_cancelled_bookings,
        'completed_bookings', v_completed_bookings,
        'completed_sessions', v_completed_sessions,
        'released_slots', v_released_slots,
        'executed_at', NOW()
    );
END;
$$;

-- 4. Aktivasi Supabase Realtime Replication Publication
DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE 
        public.bookings, 
        public.parking_sessions, 
        public.parking_slots, 
        public.system_notifications, 
        public.customer_feedbacks;
EXCEPTION WHEN OTHERS THEN NULL; END $$;
