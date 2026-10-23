-- ============================================================================
-- MIGRASI BASIS DATA: INTEGRASI BLOCKCHAIN & 4 JENIS KARTU KEANGGOTAAN
-- Tanggal: 24 Oktober 2026
-- ============================================================================

-- ----------------------------------------------------------------------------
-- FASE 3: Menambahkan Parameter Blockchain ke Tabel users
-- ----------------------------------------------------------------------------

-- 1. Tambahkan kolom alamat_dompet (Ethereum Address Sepolia)
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS alamat_dompet VARCHAR(42);

-- 2. Tambahkan kolom status_keanggotaan (Validasi status token dari blockchain)
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS status_keanggotaan BOOLEAN NOT NULL DEFAULT false;

-- 3. Pastikan kolom member_hash_code (kartu utama aktif), spending, dan savings sudah ada
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS member_hash_code VARCHAR(66);

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS monthly_spent NUMERIC(14, 2) NOT NULL DEFAULT 0.00 CHECK (monthly_spent >= 0);

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS last_spending_month VARCHAR(7) NOT NULL DEFAULT TO_CHAR(NOW(), 'YYYY-MM');

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS total_parking_count INT NOT NULL DEFAULT 0;

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS total_savings NUMERIC(12, 2) NOT NULL DEFAULT 0.00;

-- ----------------------------------------------------------------------------
-- SOLUSI 4 JENIS KARTU MEMBER (RELASI 1-KE-BANYAK)
-- Masing-masing kartu memiliki kode hash sendiri, bisa bertambah saat naik level:
-- User baru: 1 kartu -> Naik tier: 2 kartu -> 3 kartu -> 4 kartu lengkap
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.user_member_cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    card_tier VARCHAR(20) NOT NULL CHECK (card_tier IN ('regular', 'bronze', 'silver', 'gold', 'platinum')),
    member_hash_code VARCHAR(66) NOT NULL UNIQUE,
    nft_token_id NUMERIC,
    tx_hash VARCHAR(66),
    is_active BOOLEAN NOT NULL DEFAULT true,
    unlocked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_user_tier UNIQUE (user_id, card_tier)
);

-- Indeks untuk pencarian cepat berdasarkan user_id dan hash code
CREATE INDEX IF NOT EXISTS idx_user_member_cards_user_id ON public.user_member_cards(user_id);
CREATE INDEX IF NOT EXISTS idx_user_member_cards_hash ON public.user_member_cards(member_hash_code);

-- RLS (Row Level Security) untuk tabel kartu keanggotaan
ALTER TABLE public.user_member_cards ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all for authenticated and anon" ON public.user_member_cards;
CREATE POLICY "Allow all for authenticated and anon" 
ON public.user_member_cards 
FOR ALL 
USING (true) 
WITH CHECK (true);

-- ----------------------------------------------------------------------------
-- TRIGGER: GENERASI KODE HASH UNIK & KARTU BRONZE OTOMATIS SAAT USER BARU DAFTAR
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.trg_user_before_insert_membership()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF NEW.id IS NULL THEN
        NEW.id := gen_random_uuid();
    END IF;

    IF NEW.member_hash_code IS NULL OR TRIM(NEW.member_hash_code) = '' THEN
        NEW.member_hash_code := '#' || SUBSTRING(MD5(NEW.id::text || '_bronze_parksmart'), 1, 4) || '-' ||
                                      SUBSTRING(MD5(NEW.id::text || '_bronze_parksmart'), 5, 4) || '-' ||
                                      SUBSTRING(MD5(NEW.id::text || '_bronze_parksmart'), 9, 4);
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_user_before_insert ON public.users;
CREATE TRIGGER trg_user_before_insert
BEFORE INSERT ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.trg_user_before_insert_membership();

CREATE OR REPLACE FUNCTION public.trg_user_after_insert_membership()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.user_member_cards (user_id, card_tier, member_hash_code, is_active, unlocked_at)
    VALUES (NEW.id, 'regular', NEW.member_hash_code, true, NOW())
    ON CONFLICT ON CONSTRAINT uq_user_tier DO NOTHING;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_user_create_membership ON public.users;
CREATE TRIGGER trg_user_create_membership
AFTER INSERT ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.trg_user_after_insert_membership();

-- ----------------------------------------------------------------------------
-- FUNGSI: EVALUASI TIER & PENAMBAHAN KARTU BARU SAAT SPENDING (KARTU LAMA TETAP ADA)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.evaluate_user_membership_tier(
    p_user_id UUID,
    p_additional_spend NUMERIC DEFAULT 0.00
)
RETURNS TABLE (
    user_id UUID,
    member_tier member_tier_enum,
    total_spent NUMERIC,
    monthly_spent NUMERIC,
    last_spending_month VARCHAR,
    member_hash_code VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user RECORD;
    v_current_month VARCHAR(7);
    v_new_tier member_tier_enum;
    v_total NUMERIC;
    v_monthly NUMERIC;
    v_last_month VARCHAR(7);
    v_active_hash VARCHAR(32);
    v_tier_hash VARCHAR(32);
BEGIN
    SELECT * INTO v_user
    FROM public.users
    WHERE id = p_user_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN;
    END IF;

    v_current_month := TO_CHAR(NOW(), 'YYYY-MM');
    v_total := COALESCE(v_user.total_spent, 0);
    v_monthly := COALESCE(v_user.monthly_spent, 0);
    v_last_month := COALESCE(v_user.last_spending_month, v_current_month);
    v_new_tier := v_user.member_tier;

    IF v_current_month <> v_last_month THEN
        IF v_new_tier = 'PLATINUM' THEN
            IF v_monthly < 700000 THEN
                v_new_tier := 'GOLD';
            END IF;
        END IF;
        v_monthly := 0.00;
        v_last_month := v_current_month;
    END IF;

    IF p_additional_spend > 0 THEN
        v_total := v_total + p_additional_spend;
        v_monthly := v_monthly + p_additional_spend;
    END IF;

    -- Pastikan kartu BRONZE / REGULAR awal sudah ada
    v_tier_hash := '#' || SUBSTRING(MD5(p_user_id::text || '_bronze_parksmart'), 1, 4) || '-' ||
                          SUBSTRING(MD5(p_user_id::text || '_bronze_parksmart'), 5, 4) || '-' ||
                          SUBSTRING(MD5(p_user_id::text || '_bronze_parksmart'), 9, 4);
    
    INSERT INTO public.user_member_cards (user_id, card_tier, member_hash_code, is_active, unlocked_at)
    VALUES (p_user_id, 'regular', v_tier_hash, true, NOW())
    ON CONFLICT ON CONSTRAINT uq_user_tier DO NOTHING;
    
    v_active_hash := v_tier_hash;

    -- Kenaikan Tier Berdasarkan Total Belanja
    IF v_total >= 500000 THEN
        v_new_tier := 'PLATINUM';
    ELSIF v_total >= 200000 THEN
        IF v_new_tier IN ('BRONZE', 'SILVER') THEN
            v_new_tier := 'GOLD';
        END IF;
    ELSIF v_total >= 100000 THEN
        IF v_new_tier = 'BRONZE' THEN
            v_new_tier := 'SILVER';
        END IF;
    ELSE
        IF v_new_tier IS NULL THEN
            v_new_tier := 'BRONZE';
        END IF;
    END IF;

    -- Terbitkan kartu SILVER baru jika total belanja >= 100.000 (Kartu lama tetap ada!)
    IF v_total >= 100000 THEN
        v_tier_hash := '#' || SUBSTRING(MD5(p_user_id::text || '_silver_parksmart'), 1, 4) || '-' ||
                              SUBSTRING(MD5(p_user_id::text || '_silver_parksmart'), 5, 4) || '-' ||
                              SUBSTRING(MD5(p_user_id::text || '_silver_parksmart'), 9, 4);
        INSERT INTO public.user_member_cards (user_id, card_tier, member_hash_code, is_active, unlocked_at)
        VALUES (p_user_id, 'silver', v_tier_hash, true, NOW())
        ON CONFLICT ON CONSTRAINT uq_user_tier DO NOTHING;
        IF v_new_tier = 'SILVER' THEN
            v_active_hash := v_tier_hash;
        END IF;
    END IF;

    -- Terbitkan kartu GOLD baru jika total belanja >= 200.000 (Kartu lama tetap ada!)
    IF v_total >= 200000 THEN
        v_tier_hash := '#' || SUBSTRING(MD5(p_user_id::text || '_gold_parksmart'), 1, 4) || '-' ||
                              SUBSTRING(MD5(p_user_id::text || '_gold_parksmart'), 5, 4) || '-' ||
                              SUBSTRING(MD5(p_user_id::text || '_gold_parksmart'), 9, 4);
        INSERT INTO public.user_member_cards (user_id, card_tier, member_hash_code, is_active, unlocked_at)
        VALUES (p_user_id, 'gold', v_tier_hash, true, NOW())
        ON CONFLICT ON CONSTRAINT uq_user_tier DO NOTHING;
        IF v_new_tier = 'GOLD' THEN
            v_active_hash := v_tier_hash;
        END IF;
    END IF;

    -- Terbitkan kartu PLATINUM baru jika total belanja >= 500.000 (Kartu lama tetap ada!)
    IF v_total >= 500000 THEN
        v_tier_hash := '#' || SUBSTRING(MD5(p_user_id::text || '_platinum_parksmart'), 1, 4) || '-' ||
                              SUBSTRING(MD5(p_user_id::text || '_platinum_parksmart'), 5, 4) || '-' ||
                              SUBSTRING(MD5(p_user_id::text || '_platinum_parksmart'), 9, 4);
        INSERT INTO public.user_member_cards (user_id, card_tier, member_hash_code, is_active, unlocked_at)
        VALUES (p_user_id, 'platinum', v_tier_hash, true, NOW())
        ON CONFLICT ON CONSTRAINT uq_user_tier DO NOTHING;
        IF v_new_tier = 'PLATINUM' THEN
            v_active_hash := v_tier_hash;
        END IF;
    END IF;

    -- Ambil hash kode kartu aktif yang sesuai tier saat ini
    SELECT umc.member_hash_code INTO v_active_hash
    FROM public.user_member_cards umc
    WHERE umc.user_id = p_user_id 
      AND (umc.card_tier = LOWER(v_new_tier::text) OR (v_new_tier = 'BRONZE' AND umc.card_tier IN ('regular', 'bronze')))
    LIMIT 1;

    IF v_active_hash IS NULL THEN
        v_active_hash := v_tier_hash;
    END IF;

    -- Update status aktif tier tertinggi & hash code aktif pada tabel users
    UPDATE public.users u
    SET member_tier = v_new_tier,
        total_spent = v_total,
        monthly_spent = v_monthly,
        last_spending_month = v_last_month,
        member_hash_code = v_active_hash,
        updated_at = NOW()
    WHERE u.id = p_user_id;

    RETURN QUERY
    SELECT p_user_id, v_new_tier, v_total, v_monthly, v_last_month, v_active_hash;
END;
$$;
