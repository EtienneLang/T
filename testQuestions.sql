SET SERVEROUTPUT ON;

-------------------------
-- Pour faciliter ta correction
-------------------------

-------------------------
-- Question 1
-------------------------
DECLARE
    v_utilisateur_id_existe NUMBER := 1;
    v_utilisateur_id_existe_pas NUMBER := 20;
BEGIN
    IF Q10_creer_package_traitement_cnc.Q1_utilisateur_existe_FCT(v_utilisateur_id_existe) THEN
        DBMS_OUTPUT.PUT_LINE('utilisateur existe');
    ELSE
        DBMS_OUTPUT.PUT_LINE('utilisateur existe pas.');
    END IF;
    
    IF Q10_creer_package_traitement_cnc.Q1_utilisateur_existe_FCT(v_utilisateur_id_existe_pas) THEN
        DBMS_OUTPUT.PUT_LINE('utilisateur existe');
    ELSE
        DBMS_OUTPUT.PUT_LINE('utilisateur existe pas.');
    END IF;
END;
/

-------------------------
-- Question 2
-------------------------
DECLARE
    v_annonce_id NUMBER := 1; 
    v_date_debut DATE := TO_DATE('2025-04-01', 'YYYY-MM-DD');
    v_date_fin DATE := TO_DATE('2025-04-05', 'YYYY-MM-DD');
    v_date_debut_indispo DATE := TO_DATE('2024-04-02', 'YYYY-MM-DD');
    v_date_fin_indispo DATE := TO_DATE('2024-04-04', 'YYYY-MM-DD');
    v_result BOOLEAN;
BEGIN  
    v_result := Q10_creer_package_traitement_cnc.Q2_annonce_est_disponible_FCT(v_annonce_id, v_date_debut, v_date_fin);
    IF v_result THEN
        DBMS_OUTPUT.PUT_LINE('annonce disponible.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('annonce non disponible.');
    END IF;
    
    v_result := Q10_creer_package_traitement_cnc.Q2_annonce_est_disponible_FCT(v_annonce_id, v_date_debut_indispo, v_date_fin_indispo);
    IF v_result THEN
        DBMS_OUTPUT.PUT_LINE('annonce disponible.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('annonce non disponible.');
    END IF;
END;
/

-------------------------
-- Question 3
-------------------------
DECLARE
    v_annonce_id NUMBER := 1; 
    v_date_debut DATE := TO_DATE('2025-04-01', 'YYYY-MM-DD');
    v_date_fin DATE := TO_DATE('2025-04-04', 'YYYY-MM-DD');
    v_nb_personnes NUMBER := 2;
    v_total NUMBER;
BEGIN  
    v_total := Q10_creer_package_traitement_cnc.Q3_calculer_total_FCT(v_annonce_id, v_date_debut, v_date_fin, v_nb_personnes);
    DBMS_OUTPUT.PUT_LINE('Total : ' || v_total || '$');
END;
/

-------------------------
-- Question 4 (plus facile à tester à la Q7)
-------------------------
DECLARE
    v_id_user1 NUMBER := 1;
    v_id_user2 NUMBER := 2;
    v_reponse Q10_creer_package_traitement_cnc.t_message_varray;
BEGIN  
    v_reponse := Q10_creer_package_traitement_cnc.Q4_obtenir_message_historique_FCT(v_id_user1, v_id_user2);
END;
/

-------------------------
-- Question 5
-------------------------
EXEC Q10_creer_package_traitement_cnc.Q5_supprimer_annonce_PRC(9);

-------------------------
-- Question 6
-------------------------
EXEC Q10_creer_package_traitement_cnc.Q6_reserver_PRC(1,TO_DATE('2024-04-02', 'YYYY-MM-DD'),TO_DATE('2024-04-04', 'YYYY-MM-DD'),2)

-------------------------
-- Question 7
-------------------------
EXEC Q10_creer_package_traitement_cnc.Q7_afficher_converstation_PRC(1,2);

-------------------------
-- Question 8
-------------------------
EXEC Q10_creer_package_traitement_cnc.Q8_revenu_par_localisation_PRC;

-------------------------
-- Question 9
-------------------------
EXEC Q10_creer_package_traitement_cnc.Q9_reservation_par_usager_par_annonce_PRC; 