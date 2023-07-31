CREATE OR REPLACE FUNCTION XXITG_INSERT_HISTORY (
    l_xml CLOB
) RETURN VARCHAR AS

BEGIN
    
    INSERT INTO XXITG_SHIPPING_HISTORY(
        ID_TRACKING,
        ID_ATTACHMENT,
        NEW_VALUE,
        OLD_VALUE,
        CREATE_DATE
    )
        SELECT
            extractvalue(value(history), '/Data/IdTrack/text()')     ID_TRACKING,
            extractvalue(value(history), '/Data/IdAttach/text()')    ID_ATTACHMENT,
            extractvalue(value(history), '/Data/NewValue/text()')    NEW_VALUE,
            extractvalue(value(history), '/Data/OldValue/text()')    OLD_VALUE,
            TO_TIMESTAMP(extractvalue(value(history), '/Data/CreateDate/text()'),'RRRR-MM-DD"T"HH24:MI:SS.FF3"Z"')  CREATE_DATE
        FROM
                TABLE ( xmlsequence(extract(xmltype.createxml(l_xml), '/request-wrapper/Data')) ) history;
    COMMIT;
    RETURN 'success';
EXCEPTION
    WHEN no_data_found THEN
        ROLLBACK;
        --commit;
        RETURN 'Error1: '
               || sqlcode
               || sqlerrm;
    WHEN OTHERS THEN
        ROLLBACK;
        --commit;
        RETURN 'Error2: '
               || sqlcode
               || sqlerrm;
END;
