CREATE OR REPLACE FUNCTION XXITG_CANCEL_TRACK(
    p_date NUMBER
) RETURN VARCHAR AS

  CURSOR tracks IS
  SELECT * FROM XXITG_SHIPPING_TRACKING
  WHERE 1=1
  AND STATUS NOT IN ('CANCEL','CLOSED')
  AND FECHA_ENTREGA IS NULL
  AND CREATE_DATE < p_date;

BEGIN
   
   FOR poste IN tracks LOOP
       INSERT INTO XXITG_SHIPPING_HISTORY(
            ID_TRACKING,
            NEW_VALUE,
            OLD_VALUE,
            CREATE_DATE,
            FIELD,
            CREATE_BY
        ) VALUES (
            poste.ID_TRACKING,
            'CANCEL',
            poste.STATUS,
            CURRENT_TIMESTAMP,
            'Status',
            'SYSTEM'
        );

        UPDATE 
            XXITG_SHIPPING_TRACKING
        SET
            STATUS = 'CANCEL'
        WHERE
            ID_TRACKING = poste.ID_TRACKING;
   END LOOP;

   COMMIT;

   RETURN 'SUCCESS';
EXCEPTION
    WHEN no_data_found THEN
        RETURN 'NO DATA';
    WHEN OTHERS THEN
        RETURN 'Error code: ' || sqlcode;
END;