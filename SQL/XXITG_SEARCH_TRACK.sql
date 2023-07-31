CREATE OR REPLACE FUNCTION XXITG_SEARCH_TRACK (
    v_inp VARCHAR
) RETURN CLOB AS

    v_data CLOB;
    CURSOR track IS
    SELECT
      *
     FROM XXITG_SHIPPING_TRACKING
     WHERE 1=1
     AND NUM_TRACKING LIKE '%' || v_inp || '%';
BEGIN
    
    FOR xy IN track LOOP
        v_data := v_data 
               ||'<Track><Trackin>'
               ||xy.NUM_TRACKING
               ||'</Trackin></Track>';
    END LOOP;

    RETURN '<DATA>'
           ||v_data
           ||'</DATA>';
EXCEPTION
    WHEN no_data_found THEN
        RETURN '<DATA><Trackin><Trackin/></Trackin></DATA>';
    WHEN OTHERS THEN
        RETURN '<DATA><Trackin><Trackin/></Trackin></DATA>';
END;