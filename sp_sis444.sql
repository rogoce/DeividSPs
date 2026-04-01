-- Procedimiento para verificar las primas de los cumulos de las renovaciones

-- CREADO: 24/01/2005 POR: Armando
-- MOd	 : 22/02/2004 por  Armando

drop procedure sp_sis444;
create procedure "informix".sp_sis444()
returning char(20),char(5),dec(16,2),dec(16,2),dec(16,2),dec(16,2);


define _no_unidad			char(5);
define _no_poliza			char(10);
define _no_documento		char(20);
define _cod_ramo			char(3);
define _cod_agt				char(5);
define _porc_comis_agt		dec(5,2);
define _suma				dec(16,2);
define _cnt					integer;
define _fecha_primer_pago	date;
define _prima_neta			dec(16,2);
define _es_terremoto        smallint;
define _prima_inc_emi		dec(16,2);
define _prima_ter_emi		dec(16,2);
define _prima_inc_cob       dec(16,2);
define _prima_ter_cob		dec(16,2);
define _es_terr				smallint;

let _cnt  = 0;
let _es_terr  = 0;

set isolation to dirty read;

begin

foreach
	select no_documento,
		   no_poliza
	  into _no_documento,
		   _no_poliza
	  from emipomae
	 where actualizado = 1
	   and nueva_renov = 'R'
	   and periodo >= '2016-01'
	   and cod_ramo in('001','003')
	 group by no_documento,no_poliza
 
	foreach
		select no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = _no_poliza

		select count(*)
          into _cnt
          from emicupol
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;
		   
		if _cnt is null then
			let _cnt = 0;
		end if
		if _cnt = 0 then
			continue foreach;
		end if

		select prima_incendio,
		       prima_terremoto
		  into _prima_inc_emi,
		       _prima_ter_emi
		  from emicupol
         where no_poliza = _no_poliza
           and no_unidad = _no_unidad;
		   
		let _prima_inc_cob = 0;
		let _prima_ter_cob = 0;
		foreach
			Select reacobre.es_terremoto,SUM(emipocob.prima_neta)
			  into _es_terr,_prima_neta
			  From emipocob, prdcober, reacobre
			 Where emipocob.no_poliza = _no_poliza
			   And emipocob.no_unidad = _no_unidad
			   And emipocob.cod_cobertura = prdcober.cod_cobertura
			   And prdcober.cod_cober_reas = reacobre.cod_cober_reas
			 Group by reacobre.es_terremoto
			if _es_terr = 0 then
				let _prima_inc_cob = _prima_neta;
			else
				let _prima_ter_cob = _prima_neta;			
			end if
		end foreach
		if (_prima_inc_emi <> _prima_inc_cob) OR (_prima_ter_emi <> _prima_ter_cob) then
			update emicupol
			   set prima_incendio  = _prima_inc_cob,
			       prima_terremoto = _prima_ter_cob
			 where no_poliza       = _no_poliza
               and no_unidad       = _no_unidad;
				
			update endcuend
			   set prima_incendio  = _prima_inc_cob,
			       prima_terremoto = _prima_ter_cob
			 where no_poliza       = _no_poliza
			   and no_endoso       = '00000'
               and no_unidad       = _no_unidad;
			   
			return _no_documento,_no_unidad,_prima_inc_emi,_prima_inc_cob,_prima_ter_emi,_prima_ter_cob with resume;
		end if
		
	end foreach
end foreach	
end
--commit work;
end procedure;

