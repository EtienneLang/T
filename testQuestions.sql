SET SERVEROUTPUT ON;

-----------------------------------
-- Pour Tester la fonction Q1
-----------------------------------
DECLARE
    v_id_to_check NUMBER := -2000; -- ID � tester
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
    v_date_debut_to_check DATE := '2024-06-24'; -- Date d�but � tester
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
    v_id_user1 NUMBER := 1; -- ID � tester
    v_id_user2 NUMBER := 2;
    result_messages t_message_varray; 
BEGIN
    result_messages := obtenir_message_historique_FCT(v_id_user1, v_id_user2);
    
    FOR i IN 1..result_messages.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(
            'MessageID: ' || result_messages(i).MessageId ||
            ', ExpediteurUtilisateurID: ' || result_messages(i).ExpediteurUtilisateurID ||
            ', DestinataireUtilisateurID: ' || result_messages(i).DestinataireUtilisateurID ||
            ', Contenu: ' || result_messages(i).Contenu ||
            ', DateEnvoi: ' || TO_CHAR(result_messages(i).DateEnvoi, 'YYYY-MM-DD HH24:MI:SS')
        );
    END LOOP;
END;
/

-----------------------------------
-- Pour Tester la fonction Q5
-----------------------------------
EXEC supprimer_annonce_PRC(123)
/

-----------------------------------
-- Pour Tester la fonction Q6
-----------------------------------
EXEC reserver_PRC(3, DATE '2024-02-24', DATE '2024-04-24', 6)
/
-----------------------------------
-- Pour Tester la fonction Q7
-----------------------------------
EXEC afficher_converstation_PRC(1,2)

-----------------------------------
-- Pour Tester la fonction Q8
-----------------------------------

EXEC revenu_par_localisation_PRC;
-----------------------------------
-- Pour Tester la fonction Q9
-----------------------------------
EXEC reservation_par_usager_par_annonce_PRC;
