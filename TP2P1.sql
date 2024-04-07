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
    -- Gestion d'erreur --
    IF i_id_user IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Paramètre NULL : L''ID utilisateur est NULL.');
    END IF;
    IF i_id_user < 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Nombre négatif en paramètre : L''ID utilisateur est négatif.');
    END IF;
    -----------------------
    SELECT COUNT(*)
    INTO v_compteur
    FROM cnc.utilisateurs
    WHERE utilisateurid = i_id_user;

    IF v_compteur = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'L''ID passé en paramètre ne correspond à rien dans la base de données.');
    END IF;

    v_reponse := true;

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
    -- Gestion d'erreur --
    IF i_id_annonce IS NULL OR i_date_debut IS NULL OR i_date_fin IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Paramètre NULL : Un paramètre est NULL.');
    END IF;
    IF i_id_annonce < 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Nombre négatif en paramètre : L''ID utilisateur est négatif.');
    END IF;
    IF i_date_fin < i_date_debut THEN 
        RAISE_APPLICATION_ERROR(-20003, 'Dates non valides : Date fin dois être plus grande que date début.');
    END IF;
    -----------------------
    SELECT COUNT(*)
    INTO v_compteur
    FROM cnc.annonces
    WHERE annonceid = i_id_annonce AND datecreation BETWEEN i_date_debut AND i_date_fin;
    
    IF v_compteur = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'L''ID passé en paramètre ne correspond à rien dans la base de données.');
    END IF;
    
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
    -- Gestion d'erreurs --
    IF i_date_debut IS NULL OR i_date_fin IS NULL OR i_nombre_personne IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Paramètre NULL : L''ID utilisateur est NULL.');
    END IF;
    IF i_nombre_personne <= 0 THEN 
        RAISE_APPLICATION_ERROR(-20002, 'Nombre de personne non valide : Le nombre de personne doit être supérieur à 0.');
    END IF;
    IF i_date_fin < i_date_debut THEN 
        RAISE_APPLICATION_ERROR(-20003, 'Dates non valides : Date fin dois être plus grande que date début.');
    END IF;
    -----------------------
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
-- Question 4
---------------
CREATE OR REPLACE TYPE t_message AS OBJECT(
    MessageId NUMBER,
    ExpediteurUtilisateurID NUMBER,
    DestinataireUtilisateurID NUMBER,
    Contenu VARCHAR2(1000),
    DateEnvoi TIMESTAMP(6)
    );
/

CREATE OR REPLACE TYPE t_message_varray AS VARRAY(100) OF t_message;
/

CREATE OR REPLACE FUNCTION obtenir_message_historique_FCT(i_id_user_1 NUMBER, i_id_user_2 NUMBER)
    RETURN t_message_varray
AS
    messages t_message_varray := t_message_varray();
BEGIN
    FOR message_trouve IN(
        SELECT * FROM messages
        WHERE (expediteurutilisateurid = i_id_user_1 AND destinataireutilisateurid = i_id_user_2)
        OR (expediteurutilisateurid = i_id_user_2 AND destinataireutilisateurid = i_id_user_1)
        ORDER BY dateenvoi
    )
    LOOP
    messages.EXTEND;
    messages(messages.LAST) := t_message(
        message_trouve.MessageID,
        message_trouve.ExpediteurUtilisateurID,
        message_trouve.DestinataireUtilisateurID,
        message_trouve.Contenu,
        message_trouve.DateEnvoi  
        );
    END LOOP;
    RETURN messages;
END;
/

---------------
-- Question 5
---------------
CREATE OR REPLACE PROCEDURE supprimer_annonce_PRC(
    i_id_annonce NUMBER)
IS
    v_compteur NUMBER;
BEGIN
    -- Gestion d'erreurs --
    IF i_id_annonce IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Paramètre NULL : Un paramètre est NULL.');
    END IF;
    IF i_id_annonce < 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Nombre négatif en paramètre : L''ID annonce est négatif.');
    END IF;
    SELECT COUNT(*) INTO v_compteur FROM annonces WHERE annonceid = i_id_annonce;
    IF v_compteur = 0 THEN 
        RAISE_APPLICATION_ERROR(-20003, 'L''ID passé en paramètre ne correspond à rien dans la base de données.');
    END IF;
    
    -----------------------
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
    -- Gestion d'erreurs --
    IF i_id_annonce IS NULL OR i_date_debut IS NULL OR i_date_fin IS NULL OR i_nombre_personne IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Paramètre NULL : Un paramètre est NULL.');
    END IF;
    IF i_id_annonce < 0 OR i_nombre_personne < 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Nombre négatif en paramètre');
    END IF;
    SELECT COUNT(*) INTO v_compteur FROM annonces WHERE annonceid = i_id_annonce;
    IF v_compteur = 0 THEN 
        RAISE_APPLICATION_ERROR(-20003, 'L''ID passé en paramètre ne correspond à rien dans la base de données.');
    END IF;
    IF i_date_fin < i_date_debut THEN 
        RAISE_APPLICATION_ERROR(-20004, 'Dates non valides : Date fin dois être plus grande que date début.');
    END IF;
    -----------------------

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
CREATE OR REPLACE PROCEDURE afficher_converstation_PRC(
        i_id_user1 NUMBER,
        i_id_user2 NUMBER
    )
AS
    messages t_message_varray;
    nom_utilisateur VARCHAR2(100);
BEGIN
    messages := obtenir_message_historique_FCT(i_id_user1, i_id_user2);
    FOR i in 1..messages.COUNT
    LOOP
        SELECT prenom || ' ' || nom INTO nom_utilisateur
        FROM utilisateurs WHERE utilisateurid = messages(i).ExpediteurUtilisateurID;
        DBMS_OUTPUT.PUT_LINE(
            nom_utilisateur || ' : ' || messages(i).Contenu || ' - envoyé le ' || TO_CHAR(messages(i).DateEnvoi, 'YYYY-MM-DD HH24:MI:SS')
        );
    END LOOP;
END;
/
---------------
-- Question 8
---------------
CREATE OR REPLACE PROCEDURE revenu_par_localisation_PRC
AS 
    TYPE dict_localisation_revenu IS TABLE OF NUMBER INDEX BY VARCHAR2(200);
    revenus_par_localisation dict_localisation_revenu;
    cle_localisation VARCHAR2(200);
    total_revenue NUMBER;
BEGIN
    revenus_par_localisation := dict_localisation_revenu();
    
    FOR endroit IN (SELECT DISTINCT localisation FROM annonces) LOOP
        revenus_par_localisation(endroit.localisation) := 0;
    END LOOP;
    
    FOR endroit in (
        SELECT localisation, SUM(montantTotal) as total_revenue
        FROM annonces a
        JOIN reservations r ON a.annonceid = r.annonceid
        GROUP BY localisation
    )LOOP
        revenus_par_localisation(endroit.localisation) := endroit.total_revenue;
    END LOOP;
    
    cle_localisation := revenus_par_localisation.FIRST;
    WHILE cle_localisation IS NOT NULL LOOP
        DBMS_OUTPUT.PUT_LINE(cle_localisation || ' : ' || revenus_par_localisation(cle_localisation) || '$');
        cle_localisation := revenus_par_localisation.NEXT(cle_localisation);
    END LOOP;
END;
/
---------------
-- Question 9
---------------
set define off;

CREATE OR REPLACE PROCEDURE reservation_par_usager_par_annonce_PRC 
IS
    utilisateur utilisateurs%ROWTYPE;
BEGIN
    FOR annonce IN (SELECT * FROM annonces)
    LOOP
        DBMS_OUTPUT.PUT_LINE('Annonce ID : ' || annonce.annonceid);
        DBMS_OUTPUT.PUT_LINE('Titre : ' || annonce.titre);
        DBMS_OUTPUT.PUT_LINE('Utilisateurs & réservations :');
        FOR utilisateur_id IN (SELECT DISTINCT utilisateurid FROM reservations r WHERE r.annonceid = annonce.annonceid)
        LOOP
            SELECT * INTO utilisateur FROM utilisateurs WHERE utilisateurid = utilisateur_id.utilisateurid;
            DBMS_OUTPUT.PUT_LINE('------------------------------------');
            DBMS_OUTPUT.PUT_LINE('Utilisateur ID : ' || utilisateur.utilisateurid);
            DBMS_OUTPUT.PUT_LINE('Utilisateur Nom : ' || utilisateur.prenom || ' ' || utilisateur.nom);
            FOR reservation IN (SELECT * FROM reservations WHERE annonceid = annonce.annonceid AND utilisateurid = utilisateur.utilisateurid)
            LOOP
                DBMS_OUTPUT.PUT_LINE('--');
                DBMS_OUTPUT.PUT_LINE('Réservation ID : ' || reservation.reservationid);
                DBMS_OUTPUT.PUT_LINE('Date début : ' || reservation.datedebut);
                DBMS_OUTPUT.PUT_LINE('Date fin : ' || reservation.datefin);
            END LOOP;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE(' ');
    END LOOP;
END;
/

---------------
-- Question 10
---------------