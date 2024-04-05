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
CREATE OR REPLACE PROCEDURE reservation_par_usager_par_annonce_PRC IS
    v_number_of_clients NUMBER;
    v_number_of_reservation NUMBER;
    v_info_user utilisateurs%ROWTYPE;
    v_info_reservation reservations%ROWTYPE;
BEGIN
    SELECT COUNT(*) INTO v_number_of_clients FROM utilisateurs;
                DBMS_OUTPUT.PUT_LINE(v_number_of_clients);

    IF v_number_of_clients > 0 THEN
        FOR i IN 1..v_number_of_clients LOOP
            SELECT * INTO v_info_user FROM utilisateurs OFFSET i-1 ROWS FETCH NEXT 1 ROWS ONLY;
            DBMS_OUTPUT.PUT_LINE('- - - - - - - - - - - - - - - - - - - - -');
            DBMS_OUTPUT.PUT_LINE('Utilisateur ID : ' || v_info_user.utilisateurid);
            DBMS_OUTPUT.PUT_LINE('Utilisateur Nom : ' || v_info_user.prenom || ' ' || v_info_user.nom);
            
            SELECT COUNT(*) INTO v_number_of_reservation FROM reservations WHERE utilisateurid = v_info_user.utilisateurid;
            IF v_number_of_reservation <= 0 THEN
                DBMS_OUTPUT.PUT_LINE('AUCUNE RÉSERVATIONS');
            ELSE
                FOR n IN 1..v_number_of_reservation LOOP
                    SELECT * INTO v_info_reservation FROM reservations WHERE utilisateurid = v_info_user.utilisateurid OFFSET n-1 ROWS FETCH NEXT 1 ROWS ONLY;
                        DBMS_OUTPUT.PUT_LINE('- -');
                        DBMS_OUTPUT.PUT_LINE('Reservation ID : ' || v_info_reservation.reservationid);
                        DBMS_OUTPUT.PUT_LINE('Date début : ' || v_info_reservation.datedebut);
                        DBMS_OUTPUT.PUT_LINE('Date fin : ' || v_info_reservation.datefin);
                END LOOP;
            END IF;

        END LOOP;
    END IF;
END;


---------------
-- Question 10
---------------