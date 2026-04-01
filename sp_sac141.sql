-- Procedimiento que Verifica los montos de las reservas
-- 
-- Creado     : 29/12/2009 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac141;		

create procedure "informix".sp_sac141()
returning char(10),
		  char(10),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char (50),							  
		  char (50);							  

define _par_ase_lider		char(3);
define _porc_coas			dec(16,2);
define _porc_reas			dec(16,6);
define _no_reclamo			char(10);
define _no_tranrec			char(10);
define _transaccion			char(10);
define _variacion_tot		dec(16,2);
define _variacion_bru		dec(16,2);
define _variacion_net		dec(16,2);
define _monto_bru			dec(16,2);
define _monto2				dec(16,2);
define _monto_recup			dec(16,2);
define _monto_net			dec(16,2);

define _no_poliza			char(10);
define _cod_ramo			char(3);
define _nombre_ramo			char(50);

select par_ase_lider
  into _par_ase_lider
  from parparam 
 where cod_compania = "001";

foreach
 select no_reclamo,
	    variacion,
	    no_tranrec,
	    transaccion	
   into _no_reclamo,
	    _variacion_tot,
		_no_tranrec,
	    _transaccion	
   from rectrmae
  where periodo[1,4] = 2009
--    and periodo      = "2009-12"
    and actualizado  = 1
    and sac_asientos = 2
--	and no_tranrec   = "618094"

	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select porc_partic_coas
	  into _porc_coas
	  from reccoas
	 where no_reclamo   = _no_reclamo
	   and cod_coasegur = _par_ase_lider; 

	select porc_partic_suma
	  into _porc_reas
	  from rectrrea
	 where no_tranrec    = _no_tranrec
	   and tipo_contrato = 1;

	if _porc_reas is null then
		let _porc_reas = 0;
	end if;

	let _variacion_bru = _variacion_tot / 100 * _porc_coas;
	let _variacion_net = _variacion_bru / 100 * _porc_reas;

	-- Reserva de Siniestros

	select sum(debito + credito)
	  into _monto_bru
	  from recasien
	 where no_tranrec =    _no_tranrec
	   and cuenta     like "221%";

	if _monto_bru is null then
		let _monto_bru = 0;
	end if

	-- Reserva de Siniestros Monto Recuperable

	let _monto2 = _variacion_bru - _variacion_net;

	select sum(debito + credito)
	  into _monto_recup
	  from recasien
	 where no_tranrec =    _no_tranrec
	   and cuenta     like "222%";

	if _monto_recup is null then
		let _monto_recup = 0;
	end if

	-- Aumento/Disminucion de Reserva

	select sum(debito + credito)
	  into _monto_net
	  from recasien
	 where no_tranrec =    _no_tranrec
	   and cuenta     like "553%";

	if _monto_net is null then
		let _monto_net = 0;
	end if

	if _variacion_bru * -1 <> _monto_bru then

		return _no_tranrec,
		       _transaccion,
			   _variacion_tot,
			   _variacion_bru,
			   _monto_bru,
			   "221 - Reserva de Siniestros",
			   _nombre_ramo
			   with resume;

	end if

	if _monto2 <> _monto_recup then

		return _no_tranrec,
		       _transaccion,
			   _variacion_tot,
			   _monto2,
			   _monto_recup,
			   "222 - Reserva de Siniestros Monto Recuperable",
			   _nombre_ramo
			   with resume;

	end if

	if _variacion_net <> _monto_net then

		return _no_tranrec,
		       _transaccion,
			   _variacion_tot,
			   _variacion_net,
			   _monto_net,
			   "553 - Aumento/Disminucion de Reserva",
			   _nombre_ramo
			   with resume;

	end if

end foreach

return "",
       "",
	   0,
	   0,
	   0,
	   "Verificacion Exitosa",
	   "";

end procedure