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
calculer_total_FCT(i_date_debut DATE, i_date_fin DATE, i_nombre_personne NUMBER)
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
SELECT calculer_total_FCT(DATE '2024-02-24', DATE '2024-02-26', 6)  || '$' Total
from dual;




---------------
-- Question 4 (NE MARCHE PAS)
---------------
CREATE OR REPLACE FUNCTION 
annonce_est_dispo_FCT(i_id_user_1 NUMBER, i_id_user_2 NUMBER)
RETURN message_varray
IS
TYPE message_varray IS VARRAY(100) OF VARCHAR2(200) NOT NULL;
v_messages message_varray := message_varray();  
BEGIN
    FOR i IN (SELECT messageid, contenu
    INTO v_messages
    FROM cnc.messages
    WHERE (expediteurutilisateurid = i_id_user_1 OR expediteurutilisateurid = i_id_user_2)
    AND (destinateurutilisateurid = i_id_user_1 OR destinateurutilisateurid = i_id_user_2)) LOOP
        v_messages.EXTEND;
        v_messages.LAST := i;
    END LOOP;
    
    FOR x IN 1..v_messages.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE(x);
    END LOOP;
    RETURN v_messages;
END;

-----------------------------------
-- Pour Tester la fonction Q4
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
-- Question 5
---------------
CREATE OR REPLACE PROCEDURE supprimer_annonce_PRC(
    i_id_annonce NUMBER)
IS
BEGIN
    DELETE FROM cnc.reservations
    WHERE annonceid = i_id_annonce;
    DELETE FROM cnc.photos
    WHERE annonceid = i_id_annonce;
    DELETE FROM cnc.commentaires
    WHERE annonceid = i_id_annonce;
    DELETE FROM cnc.utilisateurs_annonces
    WHERE annonceid = i_id_annonce;
    DELETE FROM cnc.annonces
    WHERE annonceid = i_id_annonce;
END; 

-----------------------------------
-- Pour Tester la fonction Q5
-----------------------------------
EXEC supprimer_annonce_PRC(1)



---------------
-- Question 6
---------------
SET SERVEROUTPUT ON 
CREATE OR REPLACE PROCEDURE reserver_PRC(
    i_id_annonce NUMBER, 
    i_date_debut DATE, 
    i_date_fin DATE, 
    i_nombre_personne NUMBER)
IS
    v_result BOOLEAN;
    v_total NUMBER;
BEGIN
    v_result := annonce_est_dispo_FCT(i_id_annonce, i_date_debut, i_date_fin);
    IF v_result THEN 
        v_total := calculer_total_FCT(i_date_debut, i_date_fin, i_nombre_personne);
        INSERT INTO reservations(reservationid, annonceid, datedebut, datefin, statut, montanttotal) 
        VALUES (10, i_id_annonce, i_date_debut, i_date_fin, 'En Attente', v_total);
        DBMS_OUTPUT.PUT_LINE('valide');
    END IF;
END; 

-----------------------------------
-- Pour Tester la fonction Q6
-----------------------------------
EXEC reserver_PRC(3, DATE '2024-02-24', DATE '2024-04-24', 6)