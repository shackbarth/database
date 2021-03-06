
CREATE OR REPLACE FUNCTION fetchIncidentNumber() RETURNS INTEGER AS '
-- Copyright (c) 1999-2011 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _incidentNumber INTEGER;
  _test INTEGER;

BEGIN

  LOOP

    SELECT orderseq_number INTO _incidentNumber
      FROM orderseq
     WHERE (orderseq_name=''IncidentNumber'');

    UPDATE orderseq
       SET orderseq_number = (orderseq_number + 1)
     WHERE (orderseq_name=''IncidentNumber'');

    SELECT incdt_id INTO _test
      FROM incdt
     WHERE (incdt_number=_incidentNumber);

    IF (NOT FOUND) THEN
      EXIT;
    END IF;

  END LOOP;

  RETURN _incidentNumber;

END;
' LANGUAGE 'plpgsql';

