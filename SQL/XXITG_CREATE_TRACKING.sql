
CREATE OR REPLACE FUNCTION XXITG_INSERT_TRACKING (
    l_xml CLOB
) RETURN CLOB AS

    v_id_tracking    NUMBER;--id del track
    v_tracking       VARCHAR2(30) := '';-- numero de track
    v_tracking_temp  VARCHAR2(30) := '';-- para validar
    v_is_update      VARCHAR2(2) := '';-- verificar si es update
    v_response       CLOB;
BEGIN
    SELECT
       NVL(extractvalue(value(track), '/request-wrapper/Trackin/text()'),'N')
    INTO
       v_tracking_temp
    FROM
       TABLE ( xmlsequence(extract(xmltype.createxml(l_xml), '/')) ) track;

    
    IF TO_CHAR(v_tracking_temp) = TO_CHAR('N') THEN
       DBMS_OUTPUT.PUT_LINE('ENTRO A VACIO');
       v_is_update := 'N';
    END IF;

    IF TO_CHAR(v_tracking_temp) != TO_CHAR('N') THEN
       v_is_update := 'Y';
    END IF;
    
    IF TO_CHAR(v_is_update) = TO_CHAR('N') THEN
    --CREATE 
       
       SELECT s_track_num.NEXTVAL INTO v_tracking FROM DUAL;
       SELECT s_track_id.NEXTVAL INTO v_id_tracking FROM DUAL;
       DBMS_OUTPUT.PUT_LINE('CREATE: '|| v_id_tracking);
       INSERT INTO XXITG_SHIPPING_TRACKING (
           ID_TRACKING,
           NUM_TRACKING,
           DESCRIPTION,
           VALIDADOR,
           FECHA_ENTREGA,
           STATUS,
           USER_EMAIL,
           CREATE_DATE,
           CREATE_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_BY
       )
            SELECT
               v_id_tracking                                                                                                        ID_TRACKING,
               TO_CHAR('TRACKING - ' || v_tracking)                                                                                 NUM_TRACKING,
               extractvalue(value(tracking), '/request-wrapper/Description/text()')                                                 DESCRIPTION,
               extractvalue(value(tracking), '/request-wrapper/Validator/text()')                                                   VALIDADOR,
               TO_TIMESTAMP(extractvalue(value(tracking), '/request-wrapper/FechaEntrega/text()'),'RRRR-MM-DD"T"HH24:MI:SS.FF3"Z"') FECHA_ENTREGA,
               extractvalue(value(tracking), '/request-wrapper/Status/text()')                                                      STATUS,
               extractvalue(value(tracking), '/request-wrapper/UserEmail/text()')                                                   USER_EMAIL,
               TO_NUMBER(extractvalue(value(tracking), '/request-wrapper/CreateDate/text()'))                                       CREATE_DATE,
               extractvalue(value(tracking), '/request-wrapper/CreateBy/text()')                                                    CREATE_BY,
               TO_NUMBER(extractvalue(value(tracking), '/request-wrapper/LastUpdateDate/text()'))                                   LAST_UPDATE_DATE,
               extractvalue(value(tracking), '/request-wrapper/LastUpdateBy/text()')                                                LAST_UPDATE_BY
            FROM
                TABLE ( xmlsequence(extract(xmltype.createxml(l_xml), '/')) ) tracking;
        DBMS_OUTPUT.PUT_LINE(v_tracking);
        v_response := '<Response>'
                      ||'<Tracking>'
                      ||'TRACKING - ' || v_tracking
                      ||'</Tracking>'
                      ||'<IdTracking>'
                      ||v_id_tracking
                      ||'</IdTracking>'
                      ||'</Response>';
    END IF;
    IF TO_CHAR(v_is_update) = TO_CHAR('Y') THEN
        SELECT
           extractvalue(value(trackid), '/request-wrapper/IdTracking/text()'),
           extractvalue(value(trackid), '/request-wrapper/Trackin/text()')
        INTO
           v_id_tracking,
           v_tracking
        FROM
            TABLE ( xmlsequence(extract(xmltype.createxml(l_xml), '/')) ) trackid;

        DELETE FROM XXITG_SHIPPING_TRACKING WHERE ID_TRACKING = v_id_tracking;
        COMMIT;
        INSERT INTO XXITG_SHIPPING_TRACKING (
           ID_TRACKING,
           NUM_TRACKING,
           DESCRIPTION,
           VALIDADOR,
           FECHA_ENTREGA,
           STATUS,
           USER_EMAIL,
           CREATE_DATE,
           CREATE_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_BY
       )
            SELECT
               v_id_tracking                                                                                                           ID_TRACKING,
               extractvalue(value(tracking2), '/request-wrapper/Trackin/text()')                                                       NUM_TRACKING,
               extractvalue(value(tracking2), '/request-wrapper/Description/text()')                                                   DESCRIPTION,
               extractvalue(value(tracking2), '/request-wrapper/Validator/text()')                                                     VALIDADOR,
               TO_TIMESTAMP(extractvalue(value(tracking2), '/request-wrapper/FechaEntrega/text()'),'RRRR-MM-DD"T"HH24:MI:SS.FF3"Z"')   FECHA_ENTREGA,
               extractvalue(value(tracking2), '/request-wrapper/Status/text()')                                                        STATUS,
               extractvalue(value(tracking2), '/request-wrapper/UserEmail/text()')                                                     USER_EMAIL,
               TO_NUMBER(extractvalue(value(tracking2), '/request-wrapper/CreateDate/text()'))                                         CREATE_DATE,
               extractvalue(value(tracking2), '/request-wrapper/CreateBy/text()')                                                      CREATE_BY,
               TO_NUMBER(extractvalue(value(tracking2), '/request-wrapper/LastUpdateDate/text()'))                                     LAST_UPDATE_DATE,
               extractvalue(value(tracking2), '/request-wrapper/LastUpdateBy/text()')                                                  LAST_UPDATE_BY
            FROM
                TABLE ( xmlsequence(extract(xmltype.createxml(l_xml), '/')) ) tracking2;
        
        v_response := '<Response>'
                      ||'<Tracking>'
                      ||v_tracking
                      ||'</Tracking>'
                      ||'<IdTracking>'
                      ||v_id_tracking
                      ||'</IdTracking>'
                      ||'</Response>';

    END IF;
    COMMIT; 
    
    RETURN v_response;
EXCEPTION
    
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE(sqlcode);
        ROLLBACK;
        --commit;
        RETURN 'Error1: '
               || sqlcode
               || sqlerrm;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(sqlcode);
        ROLLBACK;
        --commit;
        RETURN 'Error2: '
               || sqlcode
               || sqlerrm;
END;
