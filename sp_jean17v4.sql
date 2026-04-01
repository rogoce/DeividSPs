
DROP procedure sp_jean17v4;
CREATE procedure sp_jean17v4()
RETURNING smallint,char(10),char(10);


DEFINE _no_tranrec,_no_reclamo 	CHAR(10);
define _monto,_variacion	 dec(16,2);
define _estimado,_ded,_res_ini,_res_act,_pagos dec(16,2);
define _salvamento,_recupero,_ded_pag,_ded_devuel dec(16,2);
define _cnt,_cnt2    integer;

foreach
	select no_reclamo,
	       no_tranrec
	  into _no_reclamo,
	       _no_tranrec
	  from rectrmae
	 where no_tranrec in('3029542','3024428')
	 
{'3030543','3022173','3022174','3029540','3025127','3029547','3025128','3029549','3025751','3025126','3030417','3030267','3024429','3030537',
'3025135','3026448','3026449','3026450','3029150','3025125','3029897','3029898','3029550','3030536','3022666','3022667','3022668','3022669','3030529','3025140',
'3027739','3026063','3026064','3025137','3029810','3029811','3021974','3029812','3029541','3030551','3029539','3029782','3030552','3030540','3030547','3025122',
'3030500','3028986','3028987','3029980','3029011','3023532','3023533','3023534','3027508','3025138','3028892','3030721','3030722','3030723','3025124','3025133','3030539',
'3029546','3025132','3025134','3025139','3030550','3030548','3030549')}

	select count(*)
	  into _cnt
	  from rectrcob
	 where no_tranrec = _no_tranrec;
	 
	let _monto = 0;
	let _variacion = 0;
	
	if _cnt = 1 then
		update rectrcob
		   set cod_cobertura = '01307'
		 where no_tranrec    = _no_tranrec
	       and cod_cobertura = '01657';
	else
		select sum(monto),sum(variacion)
		  into _monto,_variacion
		  from rectrcob
 		 where no_tranrec = _no_tranrec
	       and cod_cobertura in('01657','01307');
		
		select count(*)
		  into _cnt2
		  from rectrcob
 		 where no_tranrec = _no_tranrec
	       and cod_cobertura in('01307');

		if _cnt2 is null then
			let _cnt2 = 0;
		end if
		
		if _cnt2 > 0 then
			update rectrcob
			   set monto     = _monto,
				   variacion = _variacion
			 where no_tranrec = _no_tranrec
			   and cod_cobertura in('01307');
		else
			update rectrcob
			   set monto     = _monto,
				   variacion = _variacion,
				   cod_cobertura = '01307'
			 where no_tranrec = _no_tranrec
			   and cod_cobertura = '01657';
			
		end if
	end if
	
	update rectrcob
       set monto = 0,
	       variacion = 0
     where no_tranrec = _no_tranrec
       and cod_cobertura in('01657');
	   
	--*********************************Reclamos
	select count(*)
	  into _cnt
	  from recrccob
	 where no_reclamo = _no_reclamo;
	 
	let _estimado = 0;
	let _ded      = 0;
	let _res_ini  = 0;
	let _res_act  = 0;
	let _pagos	  = 0;
	let _salvamento = 0;
	let _recupero   = 0;
	let _ded_pag    = 0;
	let _ded_devuel = 0;

	if _cnt = 1 then
		update recrccob
		   set cod_cobertura = '01307'
		 where no_reclamo    = _no_reclamo
	       and cod_cobertura = '01657';
	else
		select sum(estimado),sum(deducible),sum(reserva_inicial),sum(reserva_actual),sum(pagos),sum(salvamento),sum(recupero),sum(deducible_pagado),sum(deducible_devuel)
		  into _estimado,_ded,_res_ini,_res_act,_pagos,_salvamento,_recupero,_ded_pag,_ded_devuel
		  from recrccob
 		 where no_reclamo = _no_reclamo
	       and cod_cobertura in('01657','01307');
		
		select count(*)
		  into _cnt2
		  from recrccob
 		 where no_reclamo = _no_reclamo
	       and cod_cobertura = '01307';

		if _cnt2 is null then
			let _cnt2 = 0;
		end if
		
		if _cnt2 > 0 then
			update recrccob
			   set estimado         = _estimado,
			       deducible        = _ded,
				   reserva_inicial  = _res_ini,
				   reserva_actual   = _res_act,
				   pagos            = _pagos,
				   salvamento       = _salvamento,
				   recupero         = _recupero,
				   deducible_pagado = _ded_pag,
				   deducible_devuel = _ded_devuel
			 where no_reclamo       = _no_reclamo
			   and cod_cobertura    = '01307';
		else
			update recrccob
			   set estimado         = _estimado,
			       deducible        = _ded,
				   reserva_inicial  = _res_ini,
				   reserva_actual   = _res_act,
				   pagos            = _pagos,
				   salvamento       = _salvamento,
				   recupero         = _recupero,
				   deducible_pagado = _ded_pag,
				   deducible_devuel = _ded_devuel,
				   cod_cobertura    = '01307'
			 where no_reclamo       = _no_reclamo
			   and cod_cobertura    = '01657';
			
		end if
	end if
	
	update recrccob
       set estimado        = 0,
	       deducible       = 0,
		   reserva_inicial = 0,
		   reserva_actual  = 0,
		   pagos           = 0,
		   salvamento      = 0,
		   recupero        = 0,
		   deducible_pagado = 0,
		   deducible_devuel = 0
     where no_reclamo       = _no_reclamo
       and cod_cobertura   = '01657';	
	 
	return _cnt,_no_tranrec,_no_reclamo with resume;

end foreach

END PROCEDURE;
