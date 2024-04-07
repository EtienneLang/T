CREATE OR REPLACE PACKAGE Q10_creer_package_traitement_cnc authid current_user
AS
    -- type qui représente un message
    TYPE t_message IS RECORD(
        MessageId NUMBER,
        ExpediteurUtilisateurID NUMBER,
        DestinataireUtilisateurID NUMBER,
        Contenu VARCHAR2(1000),
        DateEnvoi TIMESTAMP(6)
    );
    
    -- type qui représente un varray de messages
    TYPE t_message_varray IS VARRAY(100) OF t_message;
    
    --Fonctions
    
    FUNCTION Q1_utilisateur_existe_FCT(i_id_user IN NUMBER) RETURN BOOLEAN;
    
    FUNCTION Q2_annonce_est_disponible_FCT(i_id_annonce IN NUMBER, i_date_debut IN DATE, i_date_fin IN DATE) RETURN BOOLEAN;
    
    FUNCTION Q3_calculer_total_FCT(i_date_debut IN DATE, i_date_fin IN DATE, i_nombre_personne IN NUMBER) RETURN NUMBER;
    
    FUNCTION Q4_obtenir_message_historique_FCT(i_id_user_1 IN NUMBER, i_id_user_2 IN NUMBER) RETURN t_message_varray;
    
    --Procédures
    PROCEDURE Q5_supprimer_annonce_PRC(i_id_annonce IN NUMBER);
    
    PROCEDURE Q6_reserver_PRC(i_id_annonce IN NUMBER, i_date_debut IN DATE, i_date_fin IN DATE, i_nombre_personne IN NUMBER);
    
    PROCEDURE Q7_afficher_converstation_PRC(i_id_user1 IN NUMBER, i_id_user2 IN NUMBER);
    
    PROCEDURE Q8_revenu_par_localisation_PRC;
    
    PROCEDURE Q9_reservation_par_usager_par_annonce_PRC; 

END Q10_creer_package_traitement_cnc;
/