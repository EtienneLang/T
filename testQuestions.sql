SET SERVEROUTPUT ON;

-----------------------------------
-- Pour Tester la fonction Q1
-----------------------------------
DECLARE
    v_id_to_check NUMBER := 2; -- ID � tester
    v_result BOOLEAN; 
BEGIN
    v_result := utilisateur_existe_FCT(v_id_to_check);
    
    IF v_result THEN
        DBMS_OUTPUT.PUT_LINE('ID ' || v_id_to_check || ' exists.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('ID ' || v_id_to_check || ' does not exist.');
    END IF;
END;
/

-----------------------------------
-- Pour Tester la fonction Q2
-----------------------------------
DECLARE
    v_id_to_check NUMBER := 3; -- ID � tester
    v_date_debut_to_check DATE := '2024-02-24'; -- Date d�but � tester
    v_date_fin_to_check DATE := '2024-04-24'; -- Date fin � tester
    v_result BOOLEAN; 
BEGIN
    v_result := annonce_est_dispo_FCT(v_id_to_check, v_date_debut_to_check, v_date_fin_to_check);
    
    IF v_result THEN
        DBMS_OUTPUT.PUT_LINE('Annonce ' || v_id_to_check || ' valide.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Annonce ' || v_id_to_check || ' non valide.');
    END IF;
END;
/

-----------------------------------
-- Pour Tester la fonction Q3
-----------------------------------
SELECT calculer_total_FCT(DATE '2024-02-24', DATE '2024-02-26', 6)  || '$' Total
from dual;
/

-----------------------------------
-- Pour Tester la fonction Q4
-----------------------------------
DECLARE
    v_id_to_check NUMBER := 3; -- ID � tester
    v_date_debut_to_check DATE := '2024-02-24'; -- Date d�but � tester
    v_date_fin_to_check DATE := '2024-04-24'; -- Date fin � tester
    v_result BOOLEAN; 
BEGIN
    v_result := annonce_est_dispo_FCT(v_id_to_check, v_date_debut_to_check, v_date_fin_to_check);
    
    IF v_result THEN
        DBMS_OUTPUT.PUT_LINE('Annonce ' || v_id_to_check || ' valide.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Annonce ' || v_id_to_check || ' non valide.');
    END IF;
END;
/

-----------------------------------
-- Pour Tester la fonction Q5
-----------------------------------
EXEC supprimer_annonce_PRC(1)
/

-----------------------------------
-- Pour Tester la fonction Q6
-----------------------------------
EXEC reserver_PRC(3, DATE '2024-02-24', DATE '2024-04-24', 6)
/