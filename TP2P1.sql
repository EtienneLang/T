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
/

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
/
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
/
---------------
-- Question 4 (NE MARCHE PAS)
---------------
CREATE OR REPLACE TYPE msg_varray IS table OF VARCHAR(1000);
/

CREATE OR REPLACE FUNCTION 
    obtenir_message_historique_FCT(i_id_user_1 NUMBER, i_id_user_2 NUMBER)
    RETURN msg_varray
AS
    message_varray msg_varray := msg_varray();
BEGIN
    RETURN message_varray;
END;
/

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
/

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
/

---------------
-- Question 7
---------------

---------------
-- Question 8
---------------
---------------
-- Question 9
---------------
---------------
-- Question 10
---------------