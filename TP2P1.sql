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
    DBMS_OUTPUT.PUT_LINE(v_compteur);
    IF v_compteur = 0 THEN
        v_reponse := false;
    ELSE
        v_reponse := true;
    END IF;
    RETURN v_reponse;
END;

-----------------------------------
--Pour Tester la fonction Q1
-----------------------------------
DECLARE
    v_id_to_check NUMBER := 2; -- ID to test
    v_result BOOLEAN; -- Variable to store the result
BEGIN
    -- Call the function and store the result
    v_result := utilisateur_existe_FCT(v_id_to_check);
    
    -- Display the result
    IF v_result THEN
        DBMS_OUTPUT.PUT_LINE('ID ' || v_id_to_check || ' exists.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('ID ' || v_id_to_check || ' does not exist.');
    END IF;
END;






