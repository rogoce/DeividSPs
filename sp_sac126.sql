drop procedure sp_sac126;

create procedure sp_sac126(a_ano integer)
returning integer,
          char(50);

define _cuenta_suscrita			char(25);
define _cuenta_presupuesto		char(25);
define _cuenta_mayor			char(25);
define _cuenta_individual		char(25);
define _cuenta_colectivo		char(25);
define _cuenta_accidentes		char(25);
define _cuenta_salud			char(25);
define _cuenta_incendio			char(25);
define _cuenta_transporte		char(25);
define _cuenta_automovil		char(25);
define _cuenta_robo				char(25);
define _cuenta_responsabilidad	char(25);
define _cuenta_diversos			char(25);
define _cuenta_tecnicos			char(25);
define _cuenta_fianzas			char(25);

define _porc_individual			dec(16,2);
define _porc_colectivo			dec(16,2);
define _porc_accidentes			dec(16,2);
define _porc_salud				dec(16,2);
define _porc_incendio			dec(16,2);
define _porc_transporte			dec(16,2);
define _porc_automovil			dec(16,2);
define _porc_robo				dec(16,2);
define _porc_responsabilidad	dec(16,2);
define _porc_diversos			dec(16,2);
define _porc_tecnicos			dec(16,2);
define _porc_fianzas			dec(16,2);

define _ccosto					char(3);
define _periodo					smallint;
define _montomes				dec(16,2);
define _montoacu				dec(16,2);
define _cantidad				smallint;

define _error					integer;
define _error_desc				char(50);

let _cuenta_individual		= "01010101";
let _cuenta_colectivo		= "01010201";
let _cuenta_accidentes		= "01010301";
let _cuenta_salud			= "01010401";
let _cuenta_incendio		= "020101";
let _cuenta_transporte		= "020102";
let _cuenta_automovil		= "020103";
let _cuenta_robo			= "020107";
let _cuenta_responsabilidad	= "020106";
let _cuenta_diversos		= "02010802";
let _cuenta_tecnicos		= "02010804";
let _cuenta_fianzas		 	= "030104";

delete from sac:cglpre02 where pre2_cuenta[1,3] <> "411" and pre2_ano = a_ano;
delete from sac:cglpre01 where pre1_cuenta[1,3] <> "411" and pre1_ano = a_ano;

foreach
 select cuenta,
        individual,
		colectivo,
		accidentes,
		salud,
		incendio,
		transporte,
		automovil,
		robo,
		responsabilidad,
		diversos,
		tecnicos,
		fianzas
   into _cuenta_mayor,
        _porc_individual,
		_porc_colectivo,
		_porc_accidentes,
		_porc_salud,
		_porc_incendio,
		_porc_transporte,
		_porc_automovil,
		_porc_robo,
		_porc_responsabilidad,
		_porc_diversos,
		_porc_tecnicos,
		_porc_fianzas
   from sac:cglprepor
  where ano = a_ano

	-- Individual

	let _cuenta_suscrita    = "411" || trim(_cuenta_individual);
	let _cuenta_presupuesto = trim(_cuenta_mayor) || trim(_cuenta_individual);

	call sp_sac127(a_ano, _cuenta_presupuesto, _cuenta_suscrita, _porc_individual) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc with resume;
	end if

	-- Colectivo

	let _cuenta_suscrita    = "411" || trim(_cuenta_colectivo);
	let _cuenta_presupuesto = trim(_cuenta_mayor) || trim(_cuenta_colectivo);

	call sp_sac127(a_ano, _cuenta_presupuesto, _cuenta_suscrita, _porc_colectivo) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc with resume;
	end if

	-- Accidentes

	let _cuenta_suscrita    = "411" || trim(_cuenta_accidentes);
	let _cuenta_presupuesto = trim(_cuenta_mayor) || trim(_cuenta_accidentes);

	call sp_sac127(a_ano, _cuenta_presupuesto, _cuenta_suscrita, _porc_accidentes) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc with resume;
	end if

	-- Salud

	let _cuenta_suscrita    = "411" || trim(_cuenta_salud);
	let _cuenta_presupuesto = trim(_cuenta_mayor) || trim(_cuenta_salud);

	call sp_sac127(a_ano, _cuenta_presupuesto, _cuenta_suscrita, _porc_salud) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc with resume;
	end if

	-- Incendio

	let _cuenta_suscrita    = "411" || trim(_cuenta_incendio);
	let _cuenta_presupuesto = trim(_cuenta_mayor) || trim(_cuenta_incendio);

	call sp_sac127(a_ano, _cuenta_presupuesto, _cuenta_suscrita, _porc_incendio) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc with resume;
	end if

	-- Transporte

	let _cuenta_suscrita    = "411" || trim(_cuenta_transporte);
	let _cuenta_presupuesto = trim(_cuenta_mayor) || trim(_cuenta_transporte);

	call sp_sac127(a_ano, _cuenta_presupuesto, _cuenta_suscrita, _porc_transporte) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc with resume;
	end if

	-- Automovil

	let _cuenta_suscrita    = "411" || trim(_cuenta_automovil);
	let _cuenta_presupuesto = trim(_cuenta_mayor) || trim(_cuenta_automovil);

	call sp_sac127(a_ano, _cuenta_presupuesto, _cuenta_suscrita, _porc_automovil) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc with resume;
	end if

	-- Robo

	let _cuenta_suscrita    = "411" || trim(_cuenta_robo);
	let _cuenta_presupuesto = trim(_cuenta_mayor) || trim(_cuenta_robo);

	call sp_sac127(a_ano, _cuenta_presupuesto, _cuenta_suscrita, _porc_robo) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc with resume;
	end if

	-- Responsabilidad

	let _cuenta_suscrita    = "411" || trim(_cuenta_responsabilidad);
	let _cuenta_presupuesto = trim(_cuenta_mayor) || trim(_cuenta_responsabilidad);

	call sp_sac127(a_ano, _cuenta_presupuesto, _cuenta_suscrita, _porc_responsabilidad) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc with resume;
	end if

	-- Diversos

	let _cuenta_suscrita    = "411" || trim(_cuenta_diversos);
	let _cuenta_presupuesto = trim(_cuenta_mayor) || trim(_cuenta_diversos);

	call sp_sac127(a_ano, _cuenta_presupuesto, _cuenta_suscrita, _porc_diversos) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc with resume;
	end if

	-- Tecnicos

	let _cuenta_suscrita    = "411" || trim(_cuenta_tecnicos);
	let _cuenta_presupuesto = trim(_cuenta_mayor) || trim(_cuenta_tecnicos);

	call sp_sac127(a_ano, _cuenta_presupuesto, _cuenta_suscrita, _porc_tecnicos) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc with resume;
	end if

	-- Fianzas

	let _cuenta_suscrita    = "411" || trim(_cuenta_fianzas);
	let _cuenta_presupuesto = trim(_cuenta_mayor) || trim(_cuenta_fianzas);

	call sp_sac127(a_ano, _cuenta_presupuesto, _cuenta_suscrita, _porc_fianzas) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc with resume;
	end if

end foreach      

foreach
 select pre1_cuenta,
        pre1_ccosto
   into _cuenta_presupuesto,
        _ccosto
   from sac:cglpre01
  where pre1_cuenta[1,3] <> "411"
  
	let _montoacu = 0.00;
		
	foreach
	 select pre2_periodo,
	        pre2_montomes
	   into _periodo,
	        _montomes
	   from sac:cglpre02
	  where pre2_ano    = a_ano
	    and pre2_cuenta = _cuenta_presupuesto
	    and pre2_ccosto = _ccosto
	   order by pre2_periodo

		let _montoacu = _montoacu + _montomes;
		
		update sac:cglpre02
		   set pre2_montoacu = _montoacu
		 where pre2_ano      = a_ano
		   and pre2_cuenta   = _cuenta_presupuesto
		   and pre2_ccosto   = _ccosto
		   and pre2_periodo  = _periodo;
	                
	end foreach

	update sac:cglpre01
	   set pre1_monto  = _montoacu
	 where pre1_ano    = a_ano
	   and pre1_cuenta = _cuenta_presupuesto
	   and pre1_ccosto = _ccosto;

end foreach
         
return 0, "Actualizacion Exitosa";

end procedure