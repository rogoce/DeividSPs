-- Verificar que el deducible de las coberturas en la transaccion de pago se hayan pagado.

-- Creado    : 18/10/2019 - Autor: Armando Moreno M.

drop PROCEDURE sp_rec302a;
CREATE PROCEDURE "informix".sp_rec302a(a_periodo char(7))
RETURNING INTEGER,VARCHAR(100),char(10);

define _cod_tipotran char(3);
define _cod_cpt      char(10);
define _cnt,_perd_total smallint;
define _est_aud      smallint;
define _transaccion  char(10);
define _no_reclamo   char(10);
define _anular_nt    char(10);
define _cod_cobertura char(5);
define _n_cober       char(50);
define _ded_pag,_ded  dec(16,2);
define _no_poliza     char(10);
define _no_unidad     char(5);
define _numrecla      char(18);
define _no_tranrec    char(10);

SET ISOLATION TO DIRTY READ;

let _cnt     = 0;
let _ded_pag = 0;
let _ded     = 0;

foreach

	select no_tranrec,no_reclamo,numrecla,cod_tipotran,anular_nt
	  into _no_tranrec,_no_reclamo,_numrecla,_cod_tipotran,_anular_nt
	  from rectrmae
	 where actualizado = 0
	   and periodo = a_periodo
	   and cod_tipotran = '004'
	   and monto > 0
	   and numrecla[1,2] in('02','23')
	   
	select perd_total,
		   estatus_audiencia,
		   no_poliza,
		   no_unidad
	  into _perd_total,
		   _est_aud,
		   _no_poliza,
		   _no_unidad
	  from recrcmae
	 where no_reclamo = _no_reclamo;
 
	if _perd_total = 1 OR _est_aud in(1,7) then	--Se excepciona reclamo marcado como perdida total,o estatus aud. marcado como ganado o fut ganado.
		continue foreach;
	end if

	select count(*)
	  into _cnt
	  from rectrcon
	 where no_tranrec   = _no_tranrec
	   and cod_concepto = '006'; 		--descuenta deducible
   
	if _cnt is null then
		let _cnt = 0;
	end if
	if _cnt > 0 then	--Se excepciona concepto desc. ded.
		continue foreach;
	end if
	if _cod_tipotran not in ('004') then	--Solo N/T de pagos
		continue foreach;
	end if
	if _anular_nt is not null and trim(_anular_nt) <> "" then	--No N/T anuladas
		continue foreach;
	end if
   
	foreach
			select cod_cobertura
			  into _cod_cobertura
			  from rectrcob
			 where no_tranrec = _no_tranrec
			   and monto > 0
			   
			let _ded     = 0;
			let _ded_pag = 0;
			
			select deducible
			  into _ded
			  from emipocob
			 where no_poliza     = _no_poliza
			   and no_unidad     = _no_unidad
			   and cod_cobertura = _cod_cobertura;
			   
			if _ded <> 0 then
			
				select sum(deducible_pagado)
				  into _ded_pag
				  from recrccob
				 where no_reclamo    = _no_reclamo;
			   
				if _ded_pag <> 0 then
					exit foreach;
				else
					select nombre into _n_cober from prdcober where cod_cobertura = _cod_cobertura;
					return 1,"No se ha pagado el deducible de este Reclamo. " || _numrecla ,_no_tranrec; 
				end if
			end if
	end foreach
end foreach
return 0,"","";
END PROCEDURE
