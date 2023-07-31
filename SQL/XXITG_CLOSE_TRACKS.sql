CREATE OR REPLACE FUNCTION XXITG_CLOSE_TRACK (
     param VARCHAR
) RETURN VARCHAR AS


   CURSOR tracks IS
   SELECT * FROM XXITG_SHIPPING_TRACKING
   WHERE 1=1
   AND STATUS NOT IN ('CLOSED','CANCEL')
   AND FECHA_ENTREGA IS NOT NULL
   AND FECHA_ENTREGA < CURRENT_TIMESTAMP;
   --CLOSED, OPEN, PROCESS, CANCEL
BEGIN
    FOR trk IN tracks LOOP
        INSERT INTO XXITG_SHIPPING_HISTORY(
            ID_TRACKING,
            NEW_VALUE,
            OLD_VALUE,
            CREATE_DATE,
            FIELD,
            CREATE_BY
        ) VALUES (
            trk.ID_TRACKING,
            'CLOSED',
            trk.STATUS,
            CURRENT_TIMESTAMP,
            'Status',
            'SYSTEM'
        );
        UPDATE 
            XXITG_SHIPPING_TRACKING
        SET
            STATUS = 'CLOSED'
        WHERE
            ID_TRACKING = trk.ID_TRACKING;
    
    END LOOP;

    COMMIT;
    RETURN 'SUCCESS';
EXCEPTION
    WHEN no_data_found THEN
        RETURN 'NO DATA';
    WHEN OTHERS THEN
        RETURN 'Error code: ' || sqlcode;
END;