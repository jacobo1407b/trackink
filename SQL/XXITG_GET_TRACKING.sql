CREATE OR REPLACE FUNCTION XXITG_GET_TRACKING (
    track_num VARCHAR,
    date_entrega VARCHAR,
    start_date NUMBER,
    end_date NUMBER
) RETURN CLOB AS
    
    v_response CLOB;
    v_files CLOB;
    v_trackings CLOB;

    CURSOR track IS
    SELECT *
    FROM XXITG_SHIPPING_TRACKING
    WHERE 1=1
    AND NUM_TRACKING = NVL(track_num,NUM_TRACKING)
    --AND TO_CHAR(FECHA_ENTREGA,'YYYY-MM-DD') = NVL(date_entrega,TO_CHAR(FECHA_ENTREGA,'YYYY-MM-DD'))
    AND CREATE_DATE BETWEEN NVL(start_date,CREATE_DATE) AND NVL(end_date,CREATE_DATE)
    UNION
    SELECT *
    FROM XXITG_SHIPPING_TRACKING
    WHERE 1=1
    AND NUM_TRACKING = NVL(track_num,NUM_TRACKING)
    AND TO_CHAR(FECHA_ENTREGA,'YYYY-MM-DD') = NVL(date_entrega,TO_CHAR(FECHA_ENTREGA,'YYYY-MM-DD'))
    AND CREATE_DATE BETWEEN NVL(start_date,CREATE_DATE) AND NVL(end_date,CREATE_DATE);

    CURSOR filesTrack (
        v_id_relation IN NUMBER
    ) IS
    SELECT
        ID_ATTACHMENT,
        FILE_NAME,
        FILE_EXT,
        FILE_HASH,
        DESCRIPTION,
        ID_TRACKING,
        CREATE_DATE,
        CREATE_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_BY
    FROM XXITG_SHIPPING_ATTACHMENTS
    WHERE ID_TRACKING = v_id_relation;
BEGIN
    
    FOR trk IN track LOOP
        v_trackings := v_trackings
                    || '<Track><Trackin>'
                    || trk.NUM_TRACKING
                    || '</Trackin><IdTracking>'
                    || trk.ID_TRACKING
                    || '</IdTracking><Description>'
                    || trk.DESCRIPTION
                    || '</Description><Validator>'
                    || trk.VALIDADOR
                    || '</Validator><FechaEntrega>'
                    || to_char(trk.FECHA_ENTREGA,'RRRR-MM-DD"T"HH24:MI:SS.FF3"Z"')
                    || '</FechaEntrega><Status>'
                    || trk.STATUS
                    || '</Status><UserEmail>'
                    || trk.USER_EMAIL
                    || '</UserEmail><CreateDate>'
                    || trk.CREATE_DATE
                    || '</CreateDate><CreateBy>'
                    || trk.CREATE_BY
                    || '</CreateBy><LastUpdateDate>'
                    || trk.LAST_UPDATE_DATE
                    || '</LastUpdateDate><LastUpdateBy>'
                    || trk.LAST_UPDATE_BY
                    || '</LastUpdateBy></Track>';

                    FOR postFile IN filesTrack(trk.ID_TRACKING) LOOP
                    v_files := v_files
                    || '<Files><IdAttachment>'
                    || postFile.ID_ATTACHMENT
                    || '</IdAttachment><FileName>'
                    || postFile.FILE_NAME
                    || '</FileName><FileExt>'
                    || postFile.FILE_EXT
                    || '</FileExt><FileHash>'
                    || postFile.FILE_HASH
                    || '</FileHash><Description>'
                    || postFile.DESCRIPTION
                    || '</Description><IdTracking>'
                    || postFile.ID_TRACKING
                    || '</IdTracking><CreateDate>'
                    || postFile.CREATE_DATE
                    || '</CreateDate><CreateBy>'
                    || postFile.CREATE_BY
                    || '</CreateBy><LastUpdateDate>'
                    || postFile.LAST_UPDATE_DATE
                    || '</LastUpdateDate><LastUpdateBy>'
                    || postFile.LAST_UPDATE_BY
                    || '</LastUpdateBy></Files>';
                    END LOOP;
    END LOOP;

    RETURN '<DATA>'
           || v_trackings
           || v_files
           || '</DATA>';
EXCEPTION
    WHEN no_data_found THEN
        RETURN '<DATA>1</DATA>';
    WHEN OTHERS THEN
        RETURN '<DATA></DATA>';
END;
    