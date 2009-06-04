CREATE OR REPLACE FUNCTION calculatetaxdetailline(text, integer)
  RETURNS SETOF taxdetail AS
$BODY$
DECLARE
  pOrderType ALIAS FOR $1;
  pOrderId ALIAS FOR $2;
  _row taxdetail%ROWTYPE;
  _qry text;
  _totaltax numeric;
  _y RECORD;
  _table text;
  
BEGIN
   _totaltax=0.0;

   IF pOrderType = 'II' THEN
     _table := 'invcitemtax';
   ELSIF pOrderType = 'BI' THEN
     _table := 'cobilltax';
   ELSIF pOrderType = 'CI' THEN
     _table := 'cmitemtax';
   END IF;
     
   _qry := 'SELECT taxhist_tax_id as tax_id, tax_code, tax_descrip, taxhist_tax, taxhist_sequence
            FROM taxhist 
             JOIN tax ON (taxhist_tax_id=tax_id) 
             JOIN pg_class ON (pg_class.oid=taxhist.tableoid) 
            WHERE ( (taxhist_parent_id = ' || pOrderId || ')
             AND (relname=''' || _table || ''') );';
    
   FOR _y IN  EXECUTE _qry
   LOOP
     _row.taxdetail_tax_id=_y.tax_id;
     _row.taxdetail_tax_code = _y.tax_code;
     _row.taxdetail_tax_descrip = _y.tax_descrip;
     _row.taxdetail_tax = _y.taxhist_tax;
     _row.taxdetail_level= 0 ;
     _row.taxdetail_taxclass_sequence= _y.taxhist_sequence;
     _totaltax = _totaltax + _y.taxhist_tax;
     RETURN NEXT _row;
   END LOOP;
  
   IF _totaltax > 0.0 THEN
     _row.taxdetail_tax_id=-1;
     _row.taxdetail_tax_code = 'Total';
     _row.taxdetail_tax_descrip = NULL;
     _row.taxdetail_tax = _totaltax;
     _row.taxdetail_level=0;
     _row.taxdetail_taxclass_sequence= NULL;
     RETURN NEXT _row;
   END IF;
 END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE;