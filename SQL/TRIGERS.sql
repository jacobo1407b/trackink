

CREATE OR REPLACE TRIGGER TR_ATTACH
 BEFORE INSERT ON XXITG_SHIPPING_ATTACHMENTS
 REFERENCING NEW AS NEW FOR EACH ROW
 DECLARE valorSecuencia NUMBER := 0;
 BEGIN
   SELECT s_attach_id.NEXTVAL INTO valorSecuencia FROM DUAL;
   :NEW.ID_ATTACHMENT := valorSecuencia;
END;

create or replace TRIGGER ADMIN.TR_HISTORY
 BEFORE INSERT ON XXITG_SHIPPING_HISTORY
 REFERENCING NEW AS NEW FOR EACH ROW
 DECLARE valorSecuencia NUMBER := 0;
 BEGIN
   SELECT s_history.NEXTVAL INTO valorSecuencia FROM DUAL;
   :NEW.ID_HISTORY := valorSecuencia;
END;

CREATE OR REPLACE TRIGGER TR_HISTORY_ADD_FILE
 BEFORE INSERT ON XXITG_SHIPPING_ATTACHMENTS
 REFERENCING NEW AS NEW FOR EACH ROW
 DECLARE valorSecuencia NUMBER := 0;
 BEGIN
   INSERT INTO XXITG_SHIPPING_HISTORY(
      ID_TRACKING,
      NEW_VALUE,
      OLD_VALUE,
      CREATE_DATE,
      FIELD,
      CREATE_BY
    ) VALUES(
      :NEW.ID_TRACKING,
      'CREATE',
      :NEW.FILE_NAME,
      CURRENT_TIMESTAMP,
      'FILE',
      :NEW.CREATE_BY
    );
    --COMMIT;
END;


CREATE OR REPLACE TRIGGER TRG_DELETE_ATTACH
    BEFORE DELETE ON XXITG_SHIPPING_ATTACHMENTS
        FOR EACH ROW
BEGIN
    INSERT INTO XXITG_SHIPPING_HISTORY(
      ID_TRACKING,
      NEW_VALUE,
      OLD_VALUE,
      CREATE_DATE,
      FIELD,
      CREATE_BY
    ) VALUES(
      :old.ID_TRACKING,
      'DELETE',
      :old.FILE_NAME,
      CURRENT_TIMESTAMP,
      'FILE',
      :old.LAST_UPDATE_BY
    );
    --COMMIT;
END;


COMMIT;--CURRENT_TIMESTAMP


--zlnzkl02uoljb7if_high