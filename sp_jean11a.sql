
DROP procedure sp_jean11a;
CREATE procedure sp_jean11a()
RETURNING integer;

DEFINE _no_unidad    CHAR(5);
define _no_documento char(20);
define _numrecla     char(18);
define _cnt,_cnt1    smallint;
define _no_poliza 	 char(10);

let _cnt = 0;
let _cnt1 = 0;
foreach
	select no_documento,
	       numrecla,
		   no_unidad
	  into _no_documento,
           _numrecla,
           _no_unidad
      from deivid_tmp:det_reclamos_ssrp		   
	
	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where numrecla = _numrecla;
	 
	select count(*)
	  into _cnt1
	  from emipocob
	 where no_poliza = _no_poliza
       and no_unidad = _no_unidad;
	
	if _cnt1 is null then
		let _cnt1 = 0;
	end if

	if _cnt1 > 0 then
		select count(*)
		  into _cnt
		  from emipocob
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura in('00119','01307','00121'); --COBERTURAS DE COLISION

		if _cnt is null then
			let _cnt = 0;
		end if
	else
		select count(*)
		  into _cnt
		  from endedcob
		 where no_poliza = _no_poliza
		   and no_endoso = '00000'
		   and no_unidad = _no_unidad
		   and cod_cobertura in('00119','01307','00121'); --COBERTURAS DE COLISION

		if _cnt is null then
			let _cnt = 0;
		end if
	end if	
	
	if _cnt = 0 then --Es RC
		update deivid_tmp:det_reclamos_ssrp
		   set es_rc = 1
		 where no_documento = _no_documento
           and no_unidad    = _no_unidad;
	end if
	 
end foreach

return 0;

END PROCEDURE;