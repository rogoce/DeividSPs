-- Hoja de Auditoria para Reclamos de Salud

-- Creado    : 20/09/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 20/09/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 27/02/2002 - Autor: Amado Perez - cambio fecha_gasto por fecha_siniestro
--                                 por orden de Rosa Elena
--
-- SIS v.2.0 - d_recl_sp_rec55_dw1 - DEIVID, S.A.

drop procedure sp_rec55b;

create procedure sp_rec55b(
a_compania		char(3), 
a_periodo1		char(7),
a_periodo2		char(7))
returning char(20),		--_numrecla,		   	  
		  varchar(50),	--_n_hospital,			  
		  dec(16,2),	--_suma_asegurada,		  
		  char(20),		--_no_documento,		  
		  date,			--_vigencia_inic,	   	  	
		  date,			--_vigencia_final,	   	   		
		  char(50),		--_n_producto,			  
		  char(1),		--_doble_cobertura_str,  
		  char(1),		--_continuidad_benef_str,
		  date,		    --_fecha_tramite,		  
		  char(10),		--_transaccion,		  
		  char(50),		--_ntipotran,			  
          char(10),     --_no_fact,			  		
		  dec(16,2),	--_gasto_fact,			  	  		
		  dec(16,2),	--_a_deducible,	   	  		
		  dec(16,2),	--_co_pago,		   	  
		  dec(16,2),	--_coaseguro,		   	  	
		  dec(16,2),	--_pago_prov,		   	  	
		  char(50),	    --_nombre_prov,	   	  
		  dec(16,2),	--_gastos_no_cub,	   	  	
		  char(50),	    --_nombre_cont,	   	  
		  char(50),	    --_nombre_recla,	   	  	
		  char(10),		--_cod_asegurado,	   	  	
		  char(100),	--_nombre_aseg,	   	  
		  char(7),		--_periodo,		   	  
		  char(50),		--_nombre_icd,		   	   		
		  dec(16,2),	--_ahorro,				  
		  char(100),	--_a_nombre_de,		  
		  integer,		--_no_cheque,			  
		  varchar(50),	--_ncobertura,	 
		  dec(16,2),	--_prima,				  
		  dec(16,2),	--_prima_bruta,			  
		  dec(16,2),	--_prima_suscrita,	  
		  dec(16,2),	--_prima_retenida,	  
		  date,			--_fecha_factura
		  date,			--_fecha_reclamo
		  char(10),    	--estatus reclamo
		  char(20),     --evento
		  char(20),     --suceso
		  char(50),		--_n_doctor
		  char(30),     --_n_lugar
		  dec(16,2),	--reserva actual salud
		  char(30),     --cedula
		  date,			--fecha_aniversario
		  integer,      --edad
		  date,         --fecha_suscripcion
		  char(50),     --corredor
		  char(30),     --subramo
		  char(50),     --exclusion
		  char(50),     --_medicamentos prolongados
		  dec(16,2),	--ded local
		  dec(16,2),	--ded fuera
		  dec(16,2),    --ded_acum
		  char(10),     --no aprobacion
		  char(50),     --hospital preaut
		  date,			--_fecha solicitud preaut
		  date,			--_fecha autorizacion preaut
		  char(10),		-- _autorizado_por preaut
		  char(15),     --_estado_preautorizacion
		  integer,      --valido por dias preaut
		  char(20),
		  char(20),
		  char(20),
		  char(20),
		  char(20),
		  char(20),
		  char(20),
		  char(20),
		  char(20),
		  char(20),
		  char(20),
		  char(20),
		  char(20),
		  char(20),
		  char(20),
		  char(20),
		  char(20),
		  char(20),
		  char(20),
		  char(20),
		  varchar(150),
		  char(8);
		  					  
define _numrecla		char(20);
define _fecha_siniestro	date;
define _cod_icd			char(10);
define _cod_cpt			char(10);
define _no_reclamo		char(10);
define _cod_reclamante	char(10);
define _cod_asegurado	char(10);
define _nombre_recla	char(100);
define _nombre_aseg		char(100);

define _gasto_fact		dec(16,2);
define _gasto_eleg		dec(16,2);
define _a_deducible		dec(16,2);
define _co_pago			dec(16,2);
define _coaseguro		dec(16,2);
define _pago_prov		dec(16,2);
define _nombre_prov		char(100);
define _gastos_no_cub	dec(16,2);

define _cod_proveedor	char(10);
define _nombre_cia 		char(50);
define _no_unidad		char(10);
define _cod_contratante	char(10);
define _nombre_cont		char(100);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _vigencia_inic	date;
define _vigencia_final	date;
define _filtro_ano		char(100);
define _filtro_aseg		char(100);
define _filtro_recla	char(100);
define _cod_tipotran    char(3);
define _fecha_gasto		date;
define _periodo			char(7);
define _dependencia		char(50);
define _cod_parentesco  char(3);
define _no_tranrec		char(10);
define _cod_hospital	char(10);
define _nombre_icd		char(100);
define _doble_cobertura	  smallint;
define _continuidad_benef smallint;
define _no_documento     char(20);
define _suma_asegurada	 dec(16,2);
define _fecha_tramite    date;
define _cod_producto     char(5);
define _n_producto       varchar(50);
define _transaccion      char(10);
define _no_requis        char(10);
define _no_cheque        integer;
define _a_nombre_de      char(100);
define _cod_cobertura    char(5);
define _ahorro           dec(16,2);
define _ncobertura       varchar(50);
define _no_fact          char(10);
define _n_hospital       varchar(50);
define _ntipotran       varchar(50);
define _continuidad_benef_str char(1);
define _doble_cobertura_str	  char(1);
define _prima			  dec(16,2);
define _prima_bruta		  dec(16,2);
define _prima_suscrita	  dec(16,2);
define _prima_retenida	  dec(16,2);
define _fecha_reclamo     date;
define _estatus_reclamo   char(1);
define _n_estatus         char(10);
define _cod_suceso        char(3);
define _cod_evento        char(3);
define _fecha_factura	  date;
define _n_evento          char(20);
define _n_suceso          char(20);
define _cod_doctor        char(10);
define _n_doctor          char(50);
define _cod_lugar         char(3);
define _n_lugar           char(30);
define _reserva_actual    dec(16,2);
define _fec_aniver        date;
define _cedula            char(30);
define _fecha_suscripcion date;
define _cod_agente        char(5);
define _n_agente          char(50);
define _cod_subramo,_cod_ramo char(3);
define _n_subramo             char(30);
define _edad              integer;
define _exclusion,_medicamentos char(50);
define _ded_local 		  dec(16,2);
define _ded_fuera		  dec(16,2);
define _monto_ded_loc     dec(16,2);
define _estado_prchar     char(15);
define _estado_pr         smallint;
define _total_dias        integer;
define _cod_hosp_pr       char(10);
define _n_cod_hosp_pr     char(50);
define _f_sol_pr,_f_aut_pr date;
define _autorizado_pr     char(10);
define _cod_icd1,_cod_icd2,_cod_icd3 char(10);
define _cod_icd4,_cod_icd5,_cod_icd6 char(10);
define _cod_icd7,_cod_icd8,_cod_icd9 char(10);
define _cod_icd10,_cod_cpt1,_cod_cpt2 char(10);
define _cod_cpt3,_cod_cpt4,_cod_cpt5 char(10);
define _cod_cpt6  char(10);
define _cod_cpt7  char(10);
define _cod_cpt8  char(10);
define _cod_cpt9  char(10);
define _cod_cpt10 char(10);
define _desc_notas_pr varchar(150);
define _nombre_cpt1,_nombre_cpt2,_nombre_cpt3,_nombre_cpt4 char(20);
define _nombre_cpt5,_nombre_cpt6,_nombre_cpt7,_nombre_cpt8 char(20);
define _nombre_cpt9,_nombre_cpt10 char(20);
define _nombre_icd1,_nombre_icd2,_nombre_icd3,_nombre_icd4 char(20);
define _nombre_icd5,_nombre_icd6,_nombre_icd7,_nombre_icd8 char(20);
define _nombre_icd9,_nombre_icd10 char(20);
define _no_aprobacion char(10);
define _user_added_tr char(8);


--define _nombre_cpt		char(100);

let _cod_suceso = null;
let _cod_evento = null;
let _n_evento  	= null;
let	_n_suceso	= null;
let _n_doctor   = null;
let _n_lugar    = null;
let _n_agente   = null;
let _exclusion  = null;
let _estado_pr  = null;
let _autorizado_pr = null;
let _reserva_actual = 0.00;
let _edad           = 0;
let _ded_local      = 0;
let _ded_fuera		= 0;
let _monto_ded_loc  = 0;
let _total_dias     = 0;
let _desc_notas_pr  = "";
let _medicamentos = null;
let _cod_icd1 = "";
let _cod_icd2 = "";
let	_cod_icd3  = "";
let	_cod_icd4  = "";
let	_cod_icd5  = "";
let	_cod_icd6  = "";
let	_cod_icd7  = "";
let	_cod_icd8  = "";
let	_cod_icd9  = "";
let	_cod_icd10 = "";
let	_cod_cpt1  = "";
let	_cod_cpt2  = "";
let	_cod_cpt3  = "";
let	_cod_cpt4  = "";
let	_cod_cpt5  = "";
let	_cod_cpt6  = "";
let	_cod_cpt7  = "";
let	_cod_cpt8  = "";
let	_cod_cpt9  = "";
let	_cod_cpt10 = "";
let	_cod_hosp_pr = "";
let _no_aprobacion = "";
let _f_aut_pr = "01/01/1900";
let _f_sol_pr = "01/01/1900";

set isolation to dirty read;
--SET DEBUG FILE TO "sp_rec55b.trc";
--trace on;


select cod_tipotran
  into _cod_tipotran
  from rectitra
 where tipo_transaccion = 4;

foreach
 select	numrecla,
		cod_icd,
        fecha_siniestro,
		cod_reclamante,
		no_reclamo,
		no_unidad,
		no_poliza,
		periodo,
		cod_hospital,
		fecha_tramite,
		cod_asegurado,
		fecha_reclamo,
		estatus_reclamo,
		cod_evento,
		cod_suceso,
		cod_doctor,
		cod_lugar,
		reserva_actual
   into	_numrecla,
		_cod_icd,
        _fecha_siniestro,
		_cod_reclamante,
		_no_reclamo,
		_no_unidad,
		_no_poliza,
		_periodo,
		_cod_hospital,
		_fecha_tramite,
		_cod_asegurado,
		_fecha_reclamo,
		_estatus_reclamo,
        _cod_evento,
		_cod_suceso,
		_cod_doctor,
		_cod_lugar,
		_reserva_actual
   from recrcmae
  where	actualizado = 1
	and periodo     between a_periodo1 and a_periodo2
	and numrecla[1,2] = '16'

	if _estatus_reclamo = 'A' then
		let _n_estatus = 'Abierto';
	elif _estatus_reclamo = 'C' then
		let _n_estatus = 'Cerrado';
	else
		let _n_estatus = 'Declinado';
	end if

	select nombre into _n_evento from recevent where cod_evento = _cod_evento;
	select nombre into _n_suceso from recsuces where cod_suceso = _cod_suceso;
	select nombre into _n_lugar  from prdlugar where cod_lugar  = _cod_lugar;

	select vigencia_inic,
	       vigencia_final,
		   cod_contratante,
		   no_documento,
		   suma_asegurada,
		   prima,
		   prima_bruta,
		   prima_suscrita,
		   prima_retenida,
		   fecha_suscripcion,
		   cod_subramo,
		   cod_ramo
	  into _vigencia_inic,
	       _vigencia_final,
		   _cod_contratante,
		   _no_documento,
		   _suma_asegurada,
		   _prima,
		   _prima_bruta,
		   _prima_suscrita,
		   _prima_retenida,
		   _fecha_suscripcion,
		   _cod_subramo,
		   _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	 foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

		 exit foreach;
	 end foreach

	 select nombre into _n_agente from agtagent where cod_agente = _cod_agente;

	 select nombre into _n_subramo from prdsubra where cod_ramo = _cod_ramo and cod_subramo = _cod_subramo;

	 select cod_producto,
	        doble_cob,
			cont_beneficios
	   into _cod_producto,
		   _doble_cobertura,
		   _continuidad_benef
	   from emipouni
	  where no_poliza = _no_poliza
	    and no_unidad = _no_unidad;

	 if _doble_cobertura = 0 then
		let _doble_cobertura_str = 'N';
	 else
		let _doble_cobertura_str = 'S';
	 end if

	 if _continuidad_benef = 0 then
		let _continuidad_benef_str = 'N';
	 else
		let _continuidad_benef_str = 'S';
	 end if

	 select nombre
	   into _n_producto
	   from prdprod
	  where cod_producto = _cod_producto;

	 select nombre
	   into _n_hospital
	   from cliclien
	  where cod_cliente = _cod_hospital;

	if _n_hospital is null then
		let _n_hospital = "";
	end if

	 select nombre
	   into _n_doctor
	   from cliclien
	  where cod_cliente = _cod_doctor;

	if _n_doctor is null then
		let _n_doctor = "";
	end if

	select nombre
	  into _nombre_icd
	  from recicd
	 where cod_icd = _cod_icd;

	if _cod_icd is null then
		let _cod_icd    = "";
		let _nombre_icd = "";
	end if

	select nombre
	  into _nombre_cont
	  from cliclien
	 where cod_cliente = _cod_contratante;

	select nombre
	  into _nombre_recla
	  from cliclien
	 where cod_cliente = _cod_reclamante;

	if _cod_asegurado is null then
		let _cod_asegurado = _cod_reclamante;
	end if

	select nombre,cedula,fecha_aniversario
	  into _nombre_aseg,_cedula,_fec_aniver
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	if _fec_aniver is not null then
		let _edad = sp_sis78(_fec_aniver);
	else
		let _edad = 0;
	end if

	foreach

	  SELECT emiproce.nombre
		INTO _exclusion
	    FROM emipreas,   
	         emiproce,   
	         emipouni  
	   WHERE ( emiproce.cod_procedimiento = emipreas.cod_procedimiento ) and  
	         ( emipouni.no_poliza = emipreas.no_poliza ) and  
	         ( emipouni.no_unidad = emipreas.no_unidad ) and  
	         ( ( emipouni.no_poliza = _no_poliza ) AND  
	         ( emipouni.no_unidad   = _no_unidad ))

		exit foreach;

	end foreach

	foreach

	 SELECT recmedic.medicamentos
	   INTO _medicamentos
	   FROM recmedic,   
	        recicd  
	  WHERE (recicd.cod_icd = recmedic.cod_icd ) and  
	        (( recmedic.no_documento = _no_documento ) AND  
	        (recmedic.cod_reclamante = _cod_reclamante ) )    

	  exit foreach;
	end foreach

	foreach

		SELECT p.deducible_local,
		       p.deducible_fuera
		  INTO _ded_local,
		       _ded_fuera
		  FROM prdprod p, emipouni a
	     WHERE a.cod_producto = p.cod_producto
	       AND no_poliza = _no_poliza
	       AND no_unidad = _no_unidad

	  exit foreach;
	end foreach

	foreach
		SELECT recacuan.monto_deducible   
--               recacuan.monto_deducible2
		  INTO _monto_ded_loc
--		       _monto_ded_fue
          FROM recacuan  
         WHERE recacuan.no_documento = _no_documento 
           AND recacuan.cod_cliente  = _cod_reclamante
		   AND recacuan.ano          = 2010
      ORDER BY recacuan.ano ASC   

	  exit foreach;

	end foreach

	foreach

		select no_aprobacion,
		       cod_cliente,
			   fecha_solicitud,
			   fecha_autorizacion,
			   autorizado_por,
			   estado,
			   total_dias,
			   cod_icd1,
			   cod_icd2,
			   cod_icd3,
			   cod_icd4,
			   cod_icd5,
			   cod_icd6,
			   cod_icd7,
			   cod_icd8,
			   cod_icd9,
			   cod_icd10,
			   cod_cpt1,
			   cod_cpt2,
			   cod_cpt3,
			   cod_cpt4,
			   cod_cpt5,
			   cod_cpt6,
			   cod_cpt7,
			   cod_cpt8,
			   cod_cpt9,
			   cod_cpt10
		  into _no_aprobacion,
		       _cod_hosp_pr,
			   _f_sol_pr,
			   _f_aut_pr,
			   _autorizado_pr,
			   _estado_pr,
			   _total_dias,
			   _cod_icd1,
			   _cod_icd2,
			   _cod_icd3,
			   _cod_icd4,
			   _cod_icd5,
			   _cod_icd6,
			   _cod_icd7,
			   _cod_icd8,
			   _cod_icd9,
			   _cod_icd10,
			   _cod_cpt1,
			   _cod_cpt2,
			   _cod_cpt3,
			   _cod_cpt4,
			   _cod_cpt5,
			   _cod_cpt6,
			   _cod_cpt7,
			   _cod_cpt8,
			   _cod_cpt9,
			   _cod_cpt10
		  from recprea1
		 where no_documento   = _no_documento
		   and cod_reclamante = _cod_reclamante

		exit foreach;

	end foreach

	if _cod_icd1 is null then
		let _cod_icd1    = "";
		let _nombre_icd1 = "";
	else
		select nombre
		  into _nombre_icd1
		  from recicd
		 where cod_icd = _cod_icd1;

	end if
	if _cod_icd2 is null then
		let _cod_icd2    = "";
		let _nombre_icd2 = "";
	else
		select nombre
		  into _nombre_icd2
		  from recicd
		 where cod_icd = _cod_icd2;
	end if
	if _cod_icd3 is null then
		let _cod_icd3    = "";
		let _nombre_icd3 = "";
	else

		select nombre
		  into _nombre_icd3
		  from recicd
		 where cod_icd = _cod_icd3;
	end if

	if _cod_icd4 is null then
		let _cod_icd4    = "";
		let _nombre_icd4 = "";
	else
		select nombre
		  into _nombre_icd4
		  from recicd
		 where cod_icd = _cod_icd4;
	end if

	if _cod_icd5 is null then
		let _cod_icd5    = "";
		let _nombre_icd5 = "";
	else
		select nombre
		  into _nombre_icd5
		  from recicd
		 where cod_icd = _cod_icd5;
	end if

	if _cod_icd6 is null then
		let _cod_icd6    = "";
		let _nombre_icd6 = "";
	else
		select nombre
		  into _nombre_icd6
		  from recicd
		 where cod_icd = _cod_icd6;
	end if

	if _cod_icd7 is null then
		let _cod_icd7    = "";
		let _nombre_icd7 = "";
	else
		select nombre
		  into _nombre_icd7
		  from recicd
		 where cod_icd = _cod_icd7;
	end if

	if _cod_icd8 is null then
		let _cod_icd8    = "";
		let _nombre_icd8 = "";
	else
		select nombre
		  into _nombre_icd8
		  from recicd
		 where cod_icd = _cod_icd8;
	end if

	if _cod_icd9 is null then
		let _cod_icd9    = "";
		let _nombre_icd9 = "";
	else
		select nombre
		  into _nombre_icd9
		  from recicd
		 where cod_icd = _cod_icd9;
	end if

	if _cod_icd10 is null then
		let _cod_icd10    = "";
		let _nombre_icd10 = "";
	else
		select nombre
		  into _nombre_icd10
		  from recicd
		 where cod_icd = _cod_icd10;
	end if

--
	select nombre
	  into _nombre_cpt1
	  from reccpt
	 where cod_cpt = _cod_cpt1;

	if _cod_cpt1 is null then
		let _cod_cpt1    = "";
		let _nombre_cpt1 = "";
	end if

	select nombre
	  into _nombre_cpt2
	  from reccpt
	 where cod_cpt = _cod_cpt2;

	if _cod_cpt2 is null then
		let _cod_cpt2    = "";
		let _nombre_cpt2 = "";
	end if

	select nombre
	  into _nombre_cpt3
	  from reccpt
	 where cod_cpt = _cod_cpt3;

	if _cod_cpt3 is null then
		let _cod_cpt3    = "";
		let _nombre_cpt3 = "";
	end if

	select nombre
	  into _nombre_cpt4
	  from reccpt
	 where cod_cpt = _cod_cpt4;

	if _cod_cpt4 is null then
		let _cod_cpt4    = "";
		let _nombre_cpt4 = "";
	end if

	select nombre
	  into _nombre_cpt5
	  from reccpt
	 where cod_cpt = _cod_cpt5;

	if _cod_cpt5 is null then
		let _cod_cpt5    = "";
		let _nombre_cpt5 = "";
	end if

	select nombre
	  into _nombre_cpt6
	  from reccpt
	 where cod_cpt = _cod_cpt6;

	if _cod_cpt6 is null then
		let _cod_cpt6    = "";
		let _nombre_cpt6 = "";
	end if

	select nombre
	  into _nombre_cpt7
	  from reccpt
	 where cod_cpt = _cod_cpt7;

	if _cod_cpt7 is null then
		let _cod_cpt7    = "";
		let _nombre_cpt7 = "";
	end if

	select nombre
	  into _nombre_cpt8
	  from reccpt
	 where cod_cpt = _cod_cpt8;

	if _cod_cpt8 is null then
		let _cod_cpt8    = "";
		let _nombre_cpt8 = "";
	end if

	select nombre
	  into _nombre_cpt9
	  from reccpt
	 where cod_cpt = _cod_cpt9;

	if _cod_cpt9 is null then
		let _cod_cpt9    = "";
		let _nombre_cpt9 = "";
	end if

	select nombre
	  into _nombre_cpt10
	  from reccpt
	 where cod_cpt = _cod_cpt10;

	if _cod_cpt10 is null then
		let _cod_cpt10    = "";
		let _nombre_cpt10 = "";
	end if
	if _cod_hosp_pr is not null then
		select nombre into _n_cod_hosp_pr from cliclien where cod_cliente = _cod_hosp_pr;
	end if

	if _estado_pr is null then
		let _estado_prchar = '';
	elif _estado_pr = 0 then
		let _estado_prchar = 'Pendiente';
	elif _estado_pr = 1 then
		let _estado_prchar = 'Autorizado';
	else
		let _estado_prchar = 'No Autorizado';
	end if

	let _desc_notas_pr = "";
	if _no_aprobacion is not null and _no_aprobacion <> "" then
		foreach
			select descripcion
			  into _desc_notas_pr
			  from prenotas
			 where no_aprobacion = _no_aprobacion

			exit foreach;

		end foreach
	else
		let _no_aprobacion = " ";
	end if
	-- Transacciones de Reclamos

	foreach
	 select cod_cliente,
			fecha,
			cod_cpt,
			no_tranrec,
			no_factura,
			transaccion,
			no_requis,
			cod_tipotran,
			fecha_factura,
			user_added
	   into	_cod_proveedor,
			_fecha_gasto,
			_cod_cpt,
			_no_tranrec,
			_no_fact,
			_transaccion,
			_no_requis,
			_cod_tipotran,
			_fecha_factura,
			_user_added_tr
	   from rectrmae
	  where no_reclamo   = _no_reclamo
	    and actualizado  = 1
		and cod_tipotran = _cod_tipotran

		if _fecha_factura is null then
			let _fecha_factura = _fecha_gasto;
		end if

	  select nombre
	    into _ntipotran
		from rectitra
	   where cod_tipotran = _cod_tipotran;

		if _no_fact is null then
			let _no_fact = "";
		end if

		if _cod_cpt is null then
			let _cod_cpt = "";
		end if

		if _no_requis is null then
			let _no_requis = "";
		else

			select no_cheque,
			       a_nombre_de
			  into _no_cheque,
			       _a_nombre_de
			  from chqchmae
			 where no_requis = _no_requis;

		end if

		if _a_nombre_de is null then
			let _a_nombre_de = "";
		end if

		select nombre
		  into _nombre_prov
		  from cliclien
		 where cod_cliente = _cod_proveedor;

		foreach
		 select	facturado,
		        elegible,
				a_deducible,
				co_pago,
				coaseguro,
				monto,
				monto_no_cubierto,
				cod_cobertura,
				ahorro
		   into	_gasto_fact,
		        _gasto_eleg,
				_a_deducible,
				_co_pago,
				_coaseguro,
				_pago_prov,
				_gastos_no_cub,
				_cod_cobertura,
				_ahorro
		   from rectrcob
		  where no_tranrec = _no_tranrec

			select nombre
			  into _ncobertura
			  from prdcober
			 where cod_cobertura = _cod_cobertura;

			return _numrecla,		   	  --1 
				   _n_hospital,			  --2
				   _suma_asegurada,		  --3
				   _no_documento,		  --4
				   _vigencia_inic,	   	  --5 
				   _vigencia_final,	   	  --6 
				   _n_producto,			  --7
				   _doble_cobertura_str,  --8
				   _continuidad_benef_str, --9
				   _fecha_tramite,		   --10
				   _transaccion,		   --11
				   _ntipotran,			   --12
			       _no_fact,			   --13
				   _gasto_fact,			   --14
				   _a_deducible,	   	   --15
				   _co_pago,		   	   --16
				   _coaseguro,		   	   --17
				   _pago_prov,		   	   --18
				   _nombre_prov,	   	   --19
				   _gastos_no_cub,	   	   --20
				   _nombre_cont,	   	   --21
				   _nombre_recla,	   	   --22
				   _cod_asegurado,	   	   --23
				   _nombre_aseg,	   	   --24
				   _periodo,		   	   --25
				   _nombre_icd,		   	   --26
				   _ahorro,				   --27
				   _a_nombre_de,		   --28
				   _no_cheque,			   --29
				   _ncobertura,			   --32
				   _prima,				   --33
				   _prima_bruta,		   --34
				   _prima_suscrita,		   --35
				   _prima_retenida,		   --36
				   _fecha_factura,		   --37
				   _fecha_reclamo,         --38
				   _n_estatus,			   --39
				   _n_evento,			   --40
				   _n_suceso,			   --41
				   _n_doctor,    		   --42
				   _n_lugar,               --43
				   _reserva_actual,		   --44
				   _cedula,				   --45
				   _fec_aniver,			   --46
				   _edad,                  --47 
				   _fecha_suscripcion,	   --48
				   _n_agente,              --49
				   _n_subramo,			   --50
				   _exclusion,             --51
				   _medicamentos,		   --52
				   _ded_local,			   --53
				   _ded_fuera,			   --54
				   _monto_ded_loc,         --55
				   _no_aprobacion,		   --56
				   _n_cod_hosp_pr,		   --57
				   _f_sol_pr,			   --58
				   _f_aut_pr,			   --59
				   _autorizado_pr,		   --60
				   _estado_prchar,         --61
				   _total_dias,			   --62
				   _nombre_icd1,
				   _nombre_icd2,
				   _nombre_icd3,
				   _nombre_icd4,
				   _nombre_icd5,
				   _nombre_icd6,
				   _nombre_icd7,
				   _nombre_icd8,
				   _nombre_icd9,
				   _nombre_icd10,
				   _nombre_cpt1,
				   _nombre_cpt2,
				   _nombre_cpt3,
				   _nombre_cpt4,
				   _nombre_cpt5,
				   _nombre_cpt6,
				   _nombre_cpt7,
				   _nombre_cpt8,
				   _nombre_cpt9,
				   _nombre_cpt10,
				   _desc_notas_pr,
				   _user_added_tr
				   with resume;

		end foreach

	end foreach

end foreach
end procedure;










