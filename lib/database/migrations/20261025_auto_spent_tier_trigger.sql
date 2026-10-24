-- ============================================================================
-- MIGRASI BASIS DATA: AUTO-EVALUATE TIER & BLOCKCHAIN CARD PENANGANAN INJECT MANUAL
-- ============================================================================
-- Trigger ini memastikan setiap kali kolom `total_spent` di tabel `users` diubah/di-inject manual:
-- 1. Tier otomatis menyesuaikan (Bronze < 100rb, Silver >= 100rb, Gold >= 200rb, Platinum >= 500rb)
-- 2. Kartu member baru (Silver, Gold, Platinum) otomatis terbit di `user_member_cards`
-- 3. Kode transaksi blockchain unik (tx_hash berawalan 0x...) terisi otomatis per member
-- 4. Status keanggotaan aktif selalu sinkron tanpa error

CREATE OR REPLACE FUNCTION public.trg_auto_evaluate_spent_membership()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_new_tier member_tier_enum;
    v_tier_hash VARCHAR(66);
    v_tx_hash VARCHAR(66);
    v_active_hash VARCHAR(66);
BEGIN
    IF (OLD.total_spent IS DISTINCT FROM NEW.total_spent) OR (OLD.member_tier IS NULL) THEN
        
        -- Evaluasi Tier Berdasarkan Total Spent Pengguna
        IF NEW.total_spent >= 500000 THEN
            v_new_tier := 'PLATINUM';
        ELSIF NEW.total_spent >= 200000 THEN
            v_new_tier := 'GOLD';
        ELSIF NEW.total_spent >= 100000 THEN
            v_new_tier := 'SILVER';
        ELSE
            v_new_tier := 'BRONZE';
        END IF;

        NEW.member_tier := v_new_tier;

        -- 1. Terbitkan/Pastikan Kartu BRONZE/REGULAR selalu ada
        v_tier_hash := '#' || SUBSTRING(MD5(NEW.id::text || '_bronze_parksmart'), 1, 4) || '-' ||
                              SUBSTRING(MD5(NEW.id::text || '_bronze_parksmart'), 5, 4) || '-' ||
                              SUBSTRING(MD5(NEW.id::text || '_bronze_parksmart'), 9, 4);
        v_tx_hash := '0x' || MD5(NEW.id::text || '_bronze_tx1') || MD5(NEW.id::text || '_bronze_tx2');

        INSERT INTO public.user_member_cards (user_id, card_tier, member_hash_code, tx_hash, is_active, unlocked_at)
        VALUES (NEW.id, 'regular', v_tier_hash, v_tx_hash, (v_new_tier = 'BRONZE'), NOW())
        ON CONFLICT ON CONSTRAINT uq_user_tier 
        DO UPDATE SET is_active = (v_new_tier = 'BRONZE'), tx_hash = EXCLUDED.tx_hash;

        v_active_hash := v_tier_hash;

        -- 2. Jika total_spent >= 100.000, terbitkan Kartu SILVER
        IF NEW.total_spent >= 100000 THEN
            v_tier_hash := '#' || SUBSTRING(MD5(NEW.id::text || '_silver_parksmart'), 1, 4) || '-' ||
                                  SUBSTRING(MD5(NEW.id::text || '_silver_parksmart'), 5, 4) || '-' ||
                                  SUBSTRING(MD5(NEW.id::text || '_silver_parksmart'), 9, 4);
            v_tx_hash := '0x' || MD5(NEW.id::text || '_silver_tx1') || MD5(NEW.id::text || '_silver_tx2');

            INSERT INTO public.user_member_cards (user_id, card_tier, member_hash_code, tx_hash, is_active, unlocked_at)
            VALUES (NEW.id, 'silver', v_tier_hash, v_tx_hash, (v_new_tier = 'SILVER'), NOW())
            ON CONFLICT ON CONSTRAINT uq_user_tier 
            DO UPDATE SET is_active = (v_new_tier = 'SILVER'), tx_hash = EXCLUDED.tx_hash;

            IF v_new_tier = 'SILVER' THEN
                v_active_hash := v_tier_hash;
            END IF;
        END IF;

        -- 3. Jika total_spent >= 200.000, terbitkan Kartu GOLD
        IF NEW.total_spent >= 200000 THEN
            v_tier_hash := '#' || SUBSTRING(MD5(NEW.id::text || '_gold_parksmart'), 1, 4) || '-' ||
                                  SUBSTRING(MD5(NEW.id::text || '_gold_parksmart'), 5, 4) || '-' ||
                                  SUBSTRING(MD5(NEW.id::text || '_gold_parksmart'), 9, 4);
            v_tx_hash := '0x' || MD5(NEW.id::text || '_gold_tx1') || MD5(NEW.id::text || '_gold_tx2');

            INSERT INTO public.user_member_cards (user_id, card_tier, member_hash_code, tx_hash, is_active, unlocked_at)
            VALUES (NEW.id, 'gold', v_tier_hash, v_tx_hash, (v_new_tier = 'GOLD'), NOW())
            ON CONFLICT ON CONSTRAINT uq_user_tier 
            DO UPDATE SET is_active = (v_new_tier = 'GOLD'), tx_hash = EXCLUDED.tx_hash;

            IF v_new_tier = 'GOLD' THEN
                v_active_hash := v_tier_hash;
            END IF;
        END IF;

        -- 4. Jika total_spent >= 500.000, terbitkan Kartu PLATINUM
        IF NEW.total_spent >= 500000 THEN
            v_tier_hash := '#' || SUBSTRING(MD5(NEW.id::text || '_platinum_parksmart'), 1, 4) || '-' ||
                                  SUBSTRING(MD5(NEW.id::text || '_platinum_parksmart'), 5, 4) || '-' ||
                                  SUBSTRING(MD5(NEW.id::text || '_platinum_parksmart'), 9, 4);
            v_tx_hash := '0x' || MD5(NEW.id::text || '_platinum_tx1') || MD5(NEW.id::text || '_platinum_tx2');

            INSERT INTO public.user_member_cards (user_id, card_tier, member_hash_code, tx_hash, is_active, unlocked_at)
            VALUES (NEW.id, 'platinum', v_tier_hash, v_tx_hash, (v_new_tier = 'PLATINUM'), NOW())
            ON CONFLICT ON CONSTRAINT uq_user_tier 
            DO UPDATE SET is_active = (v_new_tier = 'PLATINUM'), tx_hash = EXCLUDED.tx_hash;

            IF v_new_tier = 'PLATINUM' THEN
                v_active_hash := v_tier_hash;
            END IF;
        END IF;

        NEW.member_hash_code := v_active_hash;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_user_spent_membership ON public.users;
CREATE TRIGGER trg_user_spent_membership
BEFORE UPDATE OF total_spent ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.trg_auto_evaluate_spent_membership();
