---------------
-- Question 1
---------------
CREATE OR REPLACE FUNCTION 
utilisateur_existe_FCT(i_id_user NUMBER)
RETURN BOOLEAN
IS
v_compteur NUMBER;
v_reponse BOOLEAN;
BEGIN
    SELECT COUNT(*)
    INTO v_compteur
    FROM cnc.utilisateurs
    WHERE utilisateurid = i_id_user;
    IF v_compteur = 0 THEN
        v_reponse := false;
    ELSE
        v_reponse := true;
    END IF;
    RETURN v_reponse;
END;

-----------------------------------
-- Pour Tester la fonction Q1
-----------------------------------
DECLARE
    v_id_to_check NUMBER := 2; -- ID à tester
    v_result BOOLEAN; 
BEGIN
    v_result := utilisateur_existe_FCT(v_id_to_check);
    
    IF v_result THEN
        DBMS_OUTPUT.PUT_LINE('ID ' || v_id_to_check || ' exists.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('ID ' || v_id_to_check || ' does not exist.');
    END IF;
END;



---------------
-- Question 2
---------------
CREATE OR REPLACE FUNCTION 
annonce_est_dispo_FCT(i_id_annonce NUMBER, i_date_debut DATE, i_date_fin DATE)
RETURN BOOLEAN
IS
v_compteur NUMBER;
v_reponse BOOLEAN;
BEGIN
    SELECT COUNT(*)
    INTO v_compteur
    FROM cnc.annonces
    WHERE annonceid = i_id_annonce AND datecreation BETWEEN i_date_debut AND i_date_fin;
    
    IF v_compteur <= 0 THEN
        v_reponse := false;
    ELSE
        v_reponse := true;
    END IF;
    RETURN v_reponse;
END;

-----------------------------------
-- Pour Tester la fonction Q2
-----------------------------------
DECLARE
    v_id_to_check NUMBER := 3; -- ID à tester
    v_date_debut_to_check DATE := '2024-02-24'; -- Date début à tester
    v_date_fin_to_check DATE := '2024-04-24'; -- Date fin à tester
    v_result BOOLEAN; 
BEGIN
    v_result := annonce_est_dispo_FCT(v_id_to_check, v_date_debut_to_check, v_date_fin_to_check);
    
    IF v_result THEN
        DBMS_OUTPUT.PUT_LINE('Annonce ' || v_id_to_check || ' valide.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Annonce ' || v_id_to_check || ' non valide.');
    END IF;
END;



---------------
-- Question 3
---------------
CREATE OR REPLACE FUNCTION 
calculer_total_FCT(i_id_annonce NUMBER, i_date_debut DATE, i_date_fin DATE, i_nombre_personne NUMBER)
RETURN NUMBER
IS
v_nombre_jours NUMBER;
v_total NUMBER := 0;
v_prix_nettoyage NUMBER := 20;
BEGIN
    v_nombre_jours := EXTRACT(DAY FROM NUMTODSINTERVAL(i_date_fin - i_date_debut, 'DAY'));

    IF v_nombre_jours >= 2 THEN
        v_total := v_total + i_nombre_personne * v_prix_nettoyage * 2;
        IF v_nombre_jours > 2 THEN
            v_nombre_jours := v_nombre_jours - 2;
            FOR i IN 1..v_nombre_jours LOOP
                v_prix_nettoyage := v_prix_nettoyage - 2;
                IF v_prix_nettoyage < 5 THEN 
                    v_prix_nettoyage := 5;
                END IF;
                v_total := v_total + v_prix_nettoyage * i_nombre_personne;
            END LOOP;
        END IF;
    ELSE 
        v_total := v_total + i_nombre_personne * 20 * v_nombre_jours;
    END IF;
    RETURN v_total;
END;

-----------------------------------
-- Pour Tester la fonction Q3
-----------------------------------
SELECT calculer_total_FCT(3, DATE '2024-02-24', DATE '2024-02-26', 6)  || '$' Total
from dual;
