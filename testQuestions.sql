SET SERVEROUTPUT ON;

-------------------------
-- Pour faciliter ta correction i guess
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
