-- Informe para IMCS

-- Creado    : 04/09/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 31/10/2001 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_prod_sp_pro74_dw1 - DEIVID, S.A.

drop procedure sp_pro74;

create procedure sp_pro74(a_compania char(3),a_periodo  char(7))
returning char(20),		-- Poliza
		  char(5),		-- Unidad
		  char(50),		-- Subramo
		  date,			-- Fecha Efect.
		  char(100),	-- Asegurado
		  char(1),		-- Principal
		  char(1),		-- Conyugue
		  char(1),		-- Hijo
		  char(30),		-- Cedula
		  date,			-- Fecha Nac.
		  char(1),		-- Tipo
		  char(50),     -- Compania
		  smallint,		-- Pre-Existencia
		  dec(16,2);	-- Monto	

define v_no_documento		char(20);
define v_no_unidad			char(5);
define v_nombre_subramo		char(50);
define v_fecha_efectiva		date;
define v_nombre_asegurado	char(100);
define v_principal			char(1);
define v_conyugue			char(1);
define v_hijo				char(1);
define v_cedula				char(30);
define v_fecha_nac			date;
define v_tipo				char(1);
define v_nombre_cia   		char(50);
		  	
define _cod_ramo			char(3);
define _cod_subramo			char(3);
define _no_poliza			char(10);
define _fecha_emi_pol		date;
define _fecha_emi_uni		date;
define _cod_asegurado		char(10);
define _mes_espera          smallint;
define _cod_parentesco		char(3);
define _tipo_parentesco		smallint;
define _fecha_cancelacion 	date;
define _no_endoso			char(5);
define _cod_endomov			char(3);
define _periodo             char(7);
define _estatus_poliza		smallint;
define _cod_procedimiento	char(5);
define v_pre_existen		smallint;
define v_pre_exis_desc		char(50);
define v_fecha_revision		date;
define _leer_aseg			char(10);
define v_monto				dec(16,2);
define _tar_periodo			char(7);
define v_tar_tarifa			dec(16,2);
define v_tar_tarifa_5000	dec(16,2);
define _cant_certificados	integer;
define _cant_certificados2	integer;
define _cant_cert_total		integer;
define _cant_cert_5000		integer;
define _periodo_vigente     char(7);
define _vigencia_vigente	date;
define _emision_actual		date;
define _no_activo_desde		date;
define _cant_unidades   	integer;
define _periodo_unidad      char(7);

define _tar_canc_tar		dec(16,2);
define _tar_canc_acu		dec(16,2);
	
set isolation to dirty read;

--set debug file to "sp_pro74.trc";
--trace on;

--begin work;

delete from tmp_vigen;

let v_nombre_cia    = sp_sis01(a_compania); 
let _mes_espera     = 1;
let v_pre_exis_desc = "PRE-EXIS.";
let _cant_cert_5000	= 5000;

select cod_ramo
  into _cod_ramo
  from prdramo
 where ramo_sis = 5;

select cod_endomov
  into _cod_endomov
  from endtimov
 where tipo_mov = 2;

-- Polizas y Certificados Vigentes
--{
let v_tipo = 1;
let _cant_certificados    = 0;
let _periodo_vigente[5,5] = "-";

if a_periodo[6,7] = 1 then
	let _periodo_vigente[1,4] = a_periodo[1,4] - 1;
	let _periodo_vigente[6,7] = "12";
else

	let _periodo_vigente[1,4] = a_periodo[1,4];

	if (a_periodo[6,7] - 1 ) < 10 then 
		let _periodo_vigente[6,7] = "0" || (a_periodo[6,7] - 1 );
	else
		let _periodo_vigente[6,7] = (a_periodo[6,7] - 1 );
	end if	

end if

let _periodo_vigente  = _periodo_vigente;
let _vigencia_vigente = MDY(_periodo_vigente[6,7], 1, _periodo_vigente[1,4]);
let _vigencia_vigente = _vigencia_vigente;
let _emision_actual   = MDY(a_periodo[6,7], 1, a_periodo[1,4]);
let _emision_actual   = _emision_actual;

select max(periodo)
  into _tar_periodo
  from emitimcs
 where periodo <= _periodo_vigente;

select tarifa,
       tarifa_5000
  into v_tar_tarifa,
	   v_tar_tarifa_5000
  from emitimcs
 where periodo = _tar_periodo;

let v_nombre_asegurado = "CERTIFICADOS VIGENTES AL PERIODO " || _periodo_vigente || " A UNA TARIFA DE " || v_tar_tarifa;

select cantidad
  into _cant_certificados
  from emiacuce
 where periodo = _periodo_vigente;

if _cant_certificados is null then
	let _cant_certificados = 0;
end if

let _cant_cert_total = _cant_certificados;

if _cant_certificados > _cant_cert_5000 then
	let _cant_certificados2 = _cant_certificados - _cant_cert_5000;
	let _cant_certificados  = _cant_cert_5000;
else
	let _cant_certificados2 = 0.00;
end if

let v_tar_tarifa       = _cant_certificados * v_tar_tarifa;
let v_no_unidad        = _cant_certificados;

return  "",
	    v_no_unidad,
	    "",
	    "",
	    v_nombre_asegurado,
	    "",
		"",
		"",
		"",
		"",
		0,
		v_nombre_cia,
		0,
		v_tar_tarifa
		with resume;

-- A partir del certificado 5001 se paga a $1.00 (Nelda Perez (12/06/2006)

if _cant_certificados2 > 0 then
 
	let v_nombre_asegurado = "CERTIFICADOS VIGENTES AL PERIODO " || _periodo_vigente || " A UNA TARIFA DE " || v_tar_tarifa_5000;

	let v_tar_tarifa       = _cant_certificados2 * v_tar_tarifa_5000;
	let v_no_unidad        = _cant_certificados2;

	return  "",
		    v_no_unidad,
		    "",
		    "",
		    v_nombre_asegurado,
		    "",
			"",
			"",
			"",
			"",
			0,
			v_nombre_cia,
			0,
			v_tar_tarifa
			with resume;

end if

--}

-- Polizas Nuevas

let _cant_unidades = 0;

begin
on exception in(-268)
	update emiacuce
	   set cantidad  = _cant_certificados
	 where periodo   = a_periodo;
end exception
	insert into emiacuce
	values(a_periodo, _cant_certificados);
end

let v_tipo = 1;

select max(periodo)
  into _tar_periodo
  from emitimcs
 where periodo <= a_periodo;

select tarifa,
       tarifa_5000
  into v_tar_tarifa,
       v_tar_tarifa_5000
  from emitimcs
 where periodo = _tar_periodo;

if _cant_cert_total > _cant_cert_5000 then
	let v_tar_tarifa = v_tar_tarifa_5000;
end if

--{
foreach
 select no_poliza,
		fecha_suscripcion,
		no_documento,
		cod_subramo,
		estatus_poliza
   into	_no_poliza,
		_fecha_emi_pol,
		v_no_documento,
		_cod_subramo,
		_estatus_poliza
   from emipomae
  where cod_ramo    = _cod_ramo
    and cod_subramo not in ("001", "002", "003", "004", "005", "006", "013")
    and actualizado = 1
	and nueva_renov = "N"
	and periodo     = a_periodo
	
	select nombre
	  into v_nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	select count(*)
	  into _cant_certificados
	  from emipouni
	  where no_poliza = _no_poliza;

	if _cant_certificados = 1 then

		foreach
		 select no_unidad,
		        cod_asegurado,
				vigencia_inic
		   into v_no_unidad,
				_cod_asegurado,
				v_fecha_efectiva
		   from emipouni
		  where no_poliza            = _no_poliza
	--	    and month(fecha_emision) = month(_fecha_emi_pol)
	--		and	year(fecha_emision)  = year(_fecha_emi_pol)
	--	    and month(fecha_emision) = a_periodo[6,7]
	--		and	year(fecha_emision)  = a_periodo[1,4]

				let v_principal    = "*";
				let v_conyugue     = "";
				let v_hijo         = "";
				let v_pre_existen  = 0;

				select nombre,
				       cedula,
				       fecha_aniversario
				  into v_nombre_asegurado,
				       v_cedula,
				       v_fecha_nac
				  from cliclien
				 where cod_cliente = _cod_asegurado;
				 
				let _cant_unidades = _cant_unidades + 1;

				 return v_no_documento,
				        v_no_unidad,
				        v_nombre_subramo,
				        v_fecha_efectiva,
				        v_nombre_asegurado,
				        v_principal,
						v_conyugue,
						v_hijo,
						v_cedula,
						v_fecha_nac,
						v_tipo,
						v_nombre_cia,
						v_pre_existen,
						v_tar_tarifa
						with resume;

				-- Pre-Existencias para el Asegurado Principal

				foreach	
				 select	cod_procedimiento,
				        fecha
				   into	_cod_procedimiento,
				        v_fecha_revision
				   from	emipreas
				  where	no_poliza         = _no_poliza
				    and no_unidad         = v_no_unidad
				    and month(date_added) = month(_fecha_emi_pol)
					and	year(date_added)  = year(_fecha_emi_pol)

					let v_pre_existen = 1;
					
					select nombre
					  into v_nombre_asegurado
					  from emiproce
					 where cod_procedimiento = _cod_procedimiento;

					 return v_no_documento,
					        v_no_unidad,
					        v_pre_exis_desc,
					        v_fecha_revision,
					        v_nombre_asegurado,
					        v_principal,
							v_conyugue,
							v_hijo,
							"",
							"",
							v_tipo,
							v_nombre_cia,
							v_pre_existen,
							0.00
							with resume;

				end foreach

				-- Dependientes del Asegurado

				let v_principal    = "";

				foreach
				 select cod_cliente,
						cod_parentesco
				   into _cod_asegurado,
						_cod_parentesco
				   from emidepen
				  where no_poliza         = _no_poliza
				    and no_unidad         = v_no_unidad
				    and month(date_added) = month(_fecha_emi_pol)
					and	year(date_added)  = year(_fecha_emi_pol)
					 
					select nombre,
					       cedula,
					       fecha_aniversario
					  into v_nombre_asegurado,
					       v_cedula,
					       v_fecha_nac
					  from cliclien
					 where cod_cliente = _cod_asegurado;

					select tipo_pariente
					  into _tipo_parentesco
					  from emiparen
					 where cod_parentesco = _cod_parentesco;

					let v_conyugue     = "";
					let v_hijo         = "";
					let v_pre_existen  = 0;

					if   _tipo_parentesco = 1 then
						let v_conyugue = "*";
					elif _tipo_parentesco = 2 then
						let v_hijo     = "*";
					end if					
							
					 return v_no_documento,
					        v_no_unidad,
					        v_nombre_subramo,
					        v_fecha_efectiva,
					        v_nombre_asegurado,
					        v_principal,
							v_conyugue,
							v_hijo,
							v_cedula,
							v_fecha_nac,
							v_tipo,
							v_nombre_cia,
							v_pre_existen,
							0.00
							with resume;

	--}
	--{
					-- Pre-Existencias para los Dependientes

					foreach	
					 select	cod_procedimiento,
					        fecha
					   into	_cod_procedimiento,
					        v_fecha_revision
					   from	emiprede
					  where	no_poliza         = _no_poliza
					    and no_unidad         = v_no_unidad
						and cod_cliente       = _cod_asegurado
					    and month(date_added) = month(_fecha_emi_pol)
						and	year(date_added)  = year(_fecha_emi_pol)

						let v_pre_existen  = 1;
						
						select nombre
						  into v_nombre_asegurado
						  from emiproce
						 where cod_procedimiento = _cod_procedimiento;

						 return v_no_documento,
						        v_no_unidad,
						        v_pre_exis_desc,
						        v_fecha_revision,
						        v_nombre_asegurado,
						        v_principal,
								v_conyugue,
								v_hijo,
								"",
								"",
								v_tipo,
								v_nombre_cia,
								v_pre_existen,
								0.00
								with resume;

					end foreach

			end foreach

		end foreach

	else

		foreach
		 select no_unidad,
		        cod_asegurado,
				vigencia_inic
		   into v_no_unidad,
				_cod_asegurado,
				v_fecha_efectiva
		   from emipouni
		  where no_poliza            = _no_poliza
		    and month(fecha_emision) = month(_fecha_emi_pol)
			and	year(fecha_emision)  = year(_fecha_emi_pol)
	--	    and month(fecha_emision) = a_periodo[6,7]
	--		and	year(fecha_emision)  = a_periodo[1,4]

				let v_principal    = "*";
				let v_conyugue     = "";
				let v_hijo         = "";
				let v_pre_existen  = 0;

				select nombre,
				       cedula,
				       fecha_aniversario
				  into v_nombre_asegurado,
				       v_cedula,
				       v_fecha_nac
				  from cliclien
				 where cod_cliente = _cod_asegurado;
				 
				let _cant_unidades = _cant_unidades + 1;

				 return v_no_documento,
				        v_no_unidad,
				        v_nombre_subramo,
				        v_fecha_efectiva,
				        v_nombre_asegurado,
				        v_principal,
						v_conyugue,
						v_hijo,
						v_cedula,
						v_fecha_nac,
						v_tipo,
						v_nombre_cia,
						v_pre_existen,
						v_tar_tarifa
						with resume;

				-- Pre-Existencias para el Asegurado Principal

				foreach	
				 select	cod_procedimiento,
				        fecha
				   into	_cod_procedimiento,
				        v_fecha_revision
				   from	emipreas
				  where	no_poliza         = _no_poliza
				    and no_unidad         = v_no_unidad
				    and month(date_added) = month(_fecha_emi_pol)
					and	year(date_added)  = year(_fecha_emi_pol)

					let v_pre_existen = 1;
					
					select nombre
					  into v_nombre_asegurado
					  from emiproce
					 where cod_procedimiento = _cod_procedimiento;

					 return v_no_documento,
					        v_no_unidad,
					        v_pre_exis_desc,
					        v_fecha_revision,
					        v_nombre_asegurado,
					        v_principal,
							v_conyugue,
							v_hijo,
							"",
							"",
							v_tipo,
							v_nombre_cia,
							v_pre_existen,
							0.00
							with resume;

				end foreach

				-- Dependientes del Asegurado

				let v_principal    = "";

				foreach
				 select cod_cliente,
						cod_parentesco
				   into _cod_asegurado,
						_cod_parentesco
				   from emidepen
				  where no_poliza         = _no_poliza
				    and no_unidad         = v_no_unidad
				    and month(date_added) = month(_fecha_emi_pol)
					and	year(date_added)  = year(_fecha_emi_pol)
					 
					select nombre,
					       cedula,
					       fecha_aniversario
					  into v_nombre_asegurado,
					       v_cedula,
					       v_fecha_nac
					  from cliclien
					 where cod_cliente = _cod_asegurado;

					select tipo_pariente
					  into _tipo_parentesco
					  from emiparen
					 where cod_parentesco = _cod_parentesco;

					let v_conyugue     = "";
					let v_hijo         = "";
					let v_pre_existen  = 0;

					if   _tipo_parentesco = 1 then
						let v_conyugue = "*";
					elif _tipo_parentesco = 2 then
						let v_hijo     = "*";
					end if					
							
					 return v_no_documento,
					        v_no_unidad,
					        v_nombre_subramo,
					        v_fecha_efectiva,
					        v_nombre_asegurado,
					        v_principal,
							v_conyugue,
							v_hijo,
							v_cedula,
							v_fecha_nac,
							v_tipo,
							v_nombre_cia,
							v_pre_existen,
							0.00
							with resume;

	--}
	--{
					-- Pre-Existencias para los Dependientes

					foreach	
					 select	cod_procedimiento,
					        fecha
					   into	_cod_procedimiento,
					        v_fecha_revision
					   from	emiprede
					  where	no_poliza         = _no_poliza
					    and no_unidad         = v_no_unidad
						and cod_cliente       = _cod_asegurado
					    and month(date_added) = month(_fecha_emi_pol)
						and	year(date_added)  = year(_fecha_emi_pol)

						let v_pre_existen  = 1;
						
						select nombre
						  into v_nombre_asegurado
						  from emiproce
						 where cod_procedimiento = _cod_procedimiento;

						 return v_no_documento,
						        v_no_unidad,
						        v_pre_exis_desc,
						        v_fecha_revision,
						        v_nombre_asegurado,
						        v_principal,
								v_conyugue,
								v_hijo,
								"",
								"",
								v_tipo,
								v_nombre_cia,
								v_pre_existen,
								0.00
								with resume;

					end foreach

			end foreach

		end foreach

	end if

end foreach
--}

--{
-- Inclusiones de Asegurados
let v_tipo = 2;

foreach
 select u.no_unidad,
        u.cod_asegurado,
		u.vigencia_inic,
		p.no_documento,
		p.cod_subramo,
		u.fecha_emision,
		u.no_poliza,
		p.periodo
   into v_no_unidad,
		_cod_asegurado,
		v_fecha_efectiva,
		v_no_documento,
		_cod_subramo,
		_fecha_emi_pol,
		_no_poliza,
		_periodo
   from emipouni u, emipomae p
  where u.no_poliza            = p.no_poliza
	and month(u.fecha_emision) = a_periodo[6,7]
	and year(u.fecha_emision)  = a_periodo[1,4]
	and	p.cod_ramo             = _cod_ramo
    and p.cod_subramo          in ("007", "008", "009")
    and p.actualizado          = 1
--	and month(u.fecha_emision) <> p.periodo[6,7]
--	and	year(u.fecha_emision)  <> p.periodo[1,4]

	select count(*)
	  into _cant_certificados
	  from emipouni
	  where no_poliza = _no_poliza;

	if _cant_certificados = 1 then
		continue foreach;
	end if

	if month(_fecha_emi_pol) < 10 then 
		let _periodo_unidad = year(_fecha_emi_pol) || "-0" || month(_fecha_emi_pol);
	else
		let _periodo_unidad = year(_fecha_emi_pol) || "-" || month(_fecha_emi_pol);
	end if	

	if _periodo_unidad = _periodo then
		continue foreach;
	end if

	select nombre
	  into v_nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	let v_principal    = "*";
	let v_conyugue     = "";
	let v_hijo         = "";
	let v_pre_existen  = 0;

	select nombre,
	       cedula,
	       fecha_aniversario
	  into v_nombre_asegurado,
	       v_cedula,
	       v_fecha_nac
	  from cliclien
	 where cod_cliente = _cod_asegurado;
	 
	let _cant_unidades = _cant_unidades + 1;

	 return v_no_documento,
	        v_no_unidad,
	        v_nombre_subramo,
	        v_fecha_efectiva,
	        v_nombre_asegurado,
	        v_principal,
			v_conyugue,
			v_hijo,
			v_cedula,
			v_fecha_nac,
			v_tipo,
			v_nombre_cia,
			v_pre_existen,
			v_tar_tarifa
			with resume;

	-- Pre-Existencias para el Asegurado Principal

	foreach	
	 select	cod_procedimiento,
	        fecha
	   into	_cod_procedimiento,
	        v_fecha_revision
	   from	emipreas
	  where	no_poliza         = _no_poliza
	    and no_unidad         = v_no_unidad
		and month(date_added) = a_periodo[6,7]
		and year(date_added)  = a_periodo[1,4]

		let v_pre_existen = 1;
		
		select nombre
		  into v_nombre_asegurado
		  from emiproce
		 where cod_procedimiento = _cod_procedimiento;

		 return v_no_documento,
		        v_no_unidad,
		        v_pre_exis_desc,
		        v_fecha_revision,
		        v_nombre_asegurado,
		        v_principal,
				v_conyugue,
				v_hijo,
				"",
				"",
				v_tipo,
				v_nombre_cia,
				v_pre_existen,
				0.00
				with resume;

	end foreach

	-- Dependientes del Asegurado

	let v_principal    = "";

	foreach
	 select cod_cliente,
			cod_parentesco
	   into _cod_asegurado,
			_cod_parentesco
	   from emidepen
	  where no_poliza         = _no_poliza
	    and no_unidad         = v_no_unidad
	    and month(date_added) = a_periodo[6,7]
		and	year(date_added)  = a_periodo[1,4]
		 
		select nombre,
		       cedula,
		       fecha_aniversario
		  into v_nombre_asegurado,
		       v_cedula,
		       v_fecha_nac
		  from cliclien
		 where cod_cliente = _cod_asegurado;

		select tipo_pariente
		  into _tipo_parentesco
		  from emiparen
		 where cod_parentesco = _cod_parentesco;

		let v_conyugue     = "";
		let v_hijo         = "";
		let v_pre_existen  = 0;

		if   _tipo_parentesco = 1 then
			let v_conyugue = "*";
		elif _tipo_parentesco = 2 then
			let v_hijo     = "*";
		end if					
				
		 return v_no_documento,
		        v_no_unidad,
		        v_nombre_subramo,
		        v_fecha_efectiva,
		        v_nombre_asegurado,
		        v_principal,
				v_conyugue,
				v_hijo,
				v_cedula,
				v_fecha_nac,
				v_tipo,
				v_nombre_cia,
				v_pre_existen,
				0.00
				with resume;

		-- Pre-Existencias para los Dependientes

		foreach	
		 select	cod_procedimiento,
		        fecha
		   into	_cod_procedimiento,
		        v_fecha_revision
		   from	emiprede
		  where	no_poliza         = _no_poliza
		    and no_unidad         = v_no_unidad
			and cod_cliente       = _cod_asegurado
		    and month(date_added) = a_periodo[6,7]
			and	year(date_added)  = a_periodo[1,4]

			let v_pre_existen  = 1;
			
			select nombre
			  into v_nombre_asegurado
			  from emiproce
			 where cod_procedimiento = _cod_procedimiento;

			 return v_no_documento,
			        v_no_unidad,
			        v_pre_exis_desc,
			        v_fecha_revision,
			        v_nombre_asegurado,
			        v_principal,
					v_conyugue,
					v_hijo,
					"",
					"",
					v_tipo,
					v_nombre_cia,
					v_pre_existen,
					0.00
					with resume;

		end foreach

	end foreach

end foreach
--}

--{
-- Exclusiones de Asegurados

let v_tipo = 3;

select max(periodo)
  into _tar_periodo
  from emitimcs
 where periodo <= a_periodo;

select tarifa,
       tarifa_5000
  into v_tar_tarifa,
       v_tar_tarifa_5000
  from emitimcs
 where periodo = _tar_periodo;

foreach
 select u.no_unidad,
        u.cod_asegurado,
		u.vigencia_inic,
		p.no_documento,
		p.cod_subramo,
		p.no_poliza
   into v_no_unidad,
		_cod_asegurado,
		v_fecha_efectiva,
		v_no_documento,
		_cod_subramo,
		_no_poliza
   from emipouni u, emipomae p
  where u.no_poliza              = p.no_poliza
	and month(u.no_activo_desde) = a_periodo[6,7]
	and year(u.no_activo_desde)  = a_periodo[1,4]
	and	p.cod_ramo               = _cod_ramo
    and p.cod_subramo            in ("007", "008", "009")
    and p.actualizado            = 1
    
	select nombre
	  into v_nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	let v_principal    = "*";
	let v_conyugue     = "";
	let v_hijo         = "";
	let v_pre_existen  = 0;

	select nombre,
	       cedula,
	       fecha_aniversario
	  into v_nombre_asegurado,
	       v_cedula,
	       v_fecha_nac
	  from cliclien
	 where cod_cliente = _cod_asegurado;
	 
	let _cant_unidades = _cant_unidades - 1;

	 return v_no_documento,
	        v_no_unidad,
	        v_nombre_subramo,
	        v_fecha_efectiva,
	        v_nombre_asegurado,
	        v_principal,
			v_conyugue,
			v_hijo,
			v_cedula,
			v_fecha_nac,
			v_tipo,
			v_nombre_cia,
			v_pre_existen,
			(v_tar_tarifa * -1)
			with resume;

end foreach
--}

--{
-- Cancelaciones

let v_tipo = 4;

foreach
 select p.no_poliza,
		p.no_documento,
		p.cod_subramo,
        e.vigencia_inic
   into	_no_poliza,
		v_no_documento,
		_cod_subramo,
	   v_fecha_efectiva
   from emipomae p, endedmae e
  where p.cod_ramo       = _cod_ramo
    and p.no_poliza      = e.no_poliza
    and p.cod_subramo    in ("007", "008", "009")
    and p.actualizado    = 1
    and e.actualizado    = 1
	and e.periodo        = a_periodo
	and e.cod_endomov   = "002"

--	and no_documento = "1899-00209-01"

	select nombre
	  into v_nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	if month(v_fecha_efectiva) < 10 then
		let _periodo = year(v_fecha_efectiva) || "-0" || month(v_fecha_efectiva);
	else
		let _periodo = year(v_fecha_efectiva) || "-" || month(v_fecha_efectiva);
	end if

	let _tar_canc_acu = 0;

	while _periodo < a_periodo
	
		select max(periodo)
		  into _tar_periodo
		  from emitimcs
		 where periodo <= _periodo;

		select tarifa
		  into _tar_canc_tar
		  from emitimcs
		 where periodo = _tar_periodo;

		let _tar_canc_acu = _tar_canc_acu + _tar_canc_tar;

		if _periodo[6,7] = 12 then
			let _periodo[1,4] = _periodo[1,4] + 1;
			let _periodo[6,7] = "01";
		else
			if (_periodo[6,7] + 1) < 10 then 
				let _periodo[6,7] = "0" || (_periodo[6,7] + 1);
			else
				let _periodo[6,7] = (_periodo[6,7] + 1);
			end if	
		end if

		let _periodo = _periodo;

	end while

	if _tar_canc_acu = 0 then
		let _tar_canc_acu = v_tar_tarifa;
	end if

	foreach
	 select no_unidad,
	        cod_asegurado
	   into v_no_unidad,
			_cod_asegurado
	   from emipouni
	  where no_poliza = _no_poliza

			let v_principal    = "*";
			let v_conyugue     = "";
			let v_hijo         = "";
			let v_pre_existen  = 0;

			select nombre,
			       cedula,
			       fecha_aniversario
			  into v_nombre_asegurado,
			       v_cedula,
			       v_fecha_nac
			  from cliclien
			 where cod_cliente = _cod_asegurado;
			 
			let _cant_unidades = _cant_unidades - 1;

			 return v_no_documento,
			        v_no_unidad,
			        v_nombre_subramo,
			        v_fecha_efectiva,
			        v_nombre_asegurado,
			        v_principal,
					v_conyugue,
					v_hijo,
					v_cedula,
					v_fecha_nac,
					v_tipo,
					v_nombre_cia,
					v_pre_existen,
					(_tar_canc_acu * -1)
					with resume;

			let v_principal    = "";

			foreach
			 select cod_cliente,
					cod_parentesco
			   into _cod_asegurado,
					_cod_parentesco
			   from emidepen
			  where no_poliza = _no_poliza
			    and no_unidad = v_no_unidad

				select nombre,
				       cedula,
				       fecha_aniversario
				  into v_nombre_asegurado,
				       v_cedula,
				       v_fecha_nac
				  from cliclien
				 where cod_cliente = _cod_asegurado;

				select tipo_pariente
				  into _tipo_parentesco
				  from emiparen
				 where cod_parentesco = _cod_parentesco;

				let v_conyugue     = "";
				let v_hijo         = "";

				if   _tipo_parentesco = 1 then
					let v_conyugue = "*";
				elif _tipo_parentesco = 2 then
					let v_hijo     = "*";
				end if					
						
				 return v_no_documento,
				        v_no_unidad,
				        v_nombre_subramo,
				        v_fecha_efectiva,
				        v_nombre_asegurado,
				        v_principal,
						v_conyugue,
						v_hijo,
						v_cedula,
						v_fecha_nac,
						v_tipo,
						v_nombre_cia,
						v_pre_existen,
						0.00
						with resume;

		end foreach

	end foreach

end foreach
--}

-- Rehabilitaciones

let v_tipo = 5;

-- Cambio en la forma de calcular las rehabilitaciones usando en vez de la vigencia inicial
-- el periodo del endodo (Solicitado por Nelda Perez / Carlos Chamorro (12/06/2006)

foreach
 select p.no_poliza,
		p.no_documento,
		p.cod_subramo,
        e.vigencia_inic,
		e.periodo
   into	_no_poliza,
		v_no_documento,
		_cod_subramo,
	    v_fecha_efectiva,
		_periodo
   from emipomae p, endedmae e
  where p.cod_ramo       = _cod_ramo
    and p.no_poliza      = e.no_poliza
    and p.cod_subramo    in ("007", "008", "009")
    and p.actualizado    = 1
    and e.actualizado    = 1
	and e.periodo        = a_periodo
	and e.cod_endomov   = "003"

--	and no_documento = "1899-00209-01"

	select nombre
	  into v_nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

{
	if month(v_fecha_efectiva) < 10 then
		let _periodo = year(v_fecha_efectiva) || "-0" || month(v_fecha_efectiva);
	else
		let _periodo = year(v_fecha_efectiva) || "-" || month(v_fecha_efectiva);
	end if
}

	let _tar_canc_acu = 0;

	while _periodo < a_periodo
	
		select max(periodo)
		  into _tar_periodo
		  from emitimcs
		 where periodo <= _periodo;

		select tarifa,
		       tarifa_5000
		  into _tar_canc_tar,
		       v_tar_tarifa_5000
		  from emitimcs
		 where periodo = _tar_periodo;

		if _cant_cert_total > _cant_cert_5000 then
			let _tar_canc_tar = v_tar_tarifa_5000;
		end if

		let _tar_canc_acu = _tar_canc_acu + _tar_canc_tar;

		if _periodo[6,7] = 12 then
			let _periodo[1,4] = _periodo[1,4] + 1;
			let _periodo[6,7] = "01";
		else
			if (_periodo[6,7] + 1) < 10 then 
				let _periodo[6,7] = "0" || (_periodo[6,7] + 1);
			else
				let _periodo[6,7] = (_periodo[6,7] + 1);
			end if	
		end if

		let _periodo = _periodo;

	end while

	if _tar_canc_acu = 0 then
		if _cant_cert_total > _cant_cert_5000 then
			let _tar_canc_acu = v_tar_tarifa_5000;
		else
			let _tar_canc_acu = v_tar_tarifa;
		end if
	end if

	foreach
	 select no_unidad,
	        cod_asegurado
	   into v_no_unidad,
			_cod_asegurado
	   from emipouni
	  where no_poliza = _no_poliza

			let v_principal    = "*";
			let v_conyugue     = "";
			let v_hijo         = "";
			let v_pre_existen  = 0;

			select nombre,
			       cedula,
			       fecha_aniversario
			  into v_nombre_asegurado,
			       v_cedula,
			       v_fecha_nac
			  from cliclien
			 where cod_cliente = _cod_asegurado;
			 
			let _cant_unidades = _cant_unidades + 1;

			 return v_no_documento,
			        v_no_unidad,
			        v_nombre_subramo,
			        v_fecha_efectiva,
			        v_nombre_asegurado,
			        v_principal,
					v_conyugue,
					v_hijo,
					v_cedula,
					v_fecha_nac,
					v_tipo,
					v_nombre_cia,
					v_pre_existen,
					_tar_canc_acu
					with resume;

			let v_principal    = "";

			foreach
			 select cod_cliente,
					cod_parentesco
			   into _cod_asegurado,
					_cod_parentesco
			   from emidepen
			  where no_poliza = _no_poliza
			    and no_unidad = v_no_unidad

				select nombre,
				       cedula,
				       fecha_aniversario
				  into v_nombre_asegurado,
				       v_cedula,
				       v_fecha_nac
				  from cliclien
				 where cod_cliente = _cod_asegurado;

				select tipo_pariente
				  into _tipo_parentesco
				  from emiparen
				 where cod_parentesco = _cod_parentesco;

				let v_conyugue     = "";
				let v_hijo         = "";

				if   _tipo_parentesco = 1 then
					let v_conyugue = "*";
				elif _tipo_parentesco = 2 then
					let v_hijo     = "*";
				end if					
						
				 return v_no_documento,
				        v_no_unidad,
				        v_nombre_subramo,
				        v_fecha_efectiva,
				        v_nombre_asegurado,
				        v_principal,
						v_conyugue,
						v_hijo,
						v_cedula,
						v_fecha_nac,
						v_tipo,
						v_nombre_cia,
						v_pre_existen,
						0.00
						with resume;

		end foreach

	end foreach

end foreach

update emiacuce
   set cantidad = cantidad + _cant_unidades
 where periodo  = a_periodo;

--{
-- Inclusiones de Dependientes

let v_tipo         = 6;
let v_principal    = "";
let v_pre_existen  = 0;

foreach
 select u.cod_cliente,
		u.cod_parentesco,
		p.no_documento,
		u.no_unidad,
		p.cod_subramo,
		u.date_added,
		u.no_poliza
   into _cod_asegurado,
		_cod_parentesco,
		v_no_documento,
		v_no_unidad,
		_cod_subramo,
		v_fecha_efectiva,
		_no_poliza
   from emidepen u, emipomae p, emipouni d
  where u.no_poliza         = p.no_poliza
    and u.no_poliza         = d.no_poliza
	and u.no_unidad         = d.no_unidad
    and month(u.date_added) = a_periodo[6,7]
	and year(u.date_added)  = a_periodo[1,4]
	and	p.cod_ramo          = _cod_ramo
    and p.cod_subramo       in ("007", "008", "009")
    and p.actualizado       = 1
	and month(u.date_added) <> month(d.fecha_emision)
	and	year(u.date_added)  <> year(d.fecha_emision)

	select nombre
	  into v_nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	select nombre,
	       cedula,
	       fecha_aniversario
	  into v_nombre_asegurado,
	       v_cedula,
	       v_fecha_nac
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	select tipo_pariente
	  into _tipo_parentesco
	  from emiparen
	 where cod_parentesco = _cod_parentesco;

	let v_conyugue     = "";
	let v_hijo         = "";

	if   _tipo_parentesco = 1 then
		let v_conyugue = "*";
	elif _tipo_parentesco = 2 then
		let v_hijo     = "*";
	end if					
			
	 return v_no_documento,
	        v_no_unidad,
	        v_nombre_subramo,
	        v_fecha_efectiva,
	        v_nombre_asegurado,
	        v_principal,
			v_conyugue,
			v_hijo,
			v_cedula,
			v_fecha_nac,
			v_tipo,
			v_nombre_cia,
			v_pre_existen,
			0.00
			with resume;

	-- Pre-Existencias para los Dependientes

	foreach	
	 select	cod_procedimiento,
	        fecha
	   into	_cod_procedimiento,
	        v_fecha_revision
	   from	emiprede
	  where	no_poliza   = _no_poliza
	    and no_unidad   = v_no_unidad
		and cod_cliente = _cod_asegurado
		and date_added  = v_fecha_efectiva

		let v_pre_existen  = 1;
		
		select nombre
		  into v_nombre_asegurado
		  from emiproce
		 where cod_procedimiento = _cod_procedimiento;

		 return v_no_documento,
		        v_no_unidad,
		        v_pre_exis_desc,
		        v_fecha_revision,
		        v_nombre_asegurado,
		        v_principal,
				v_conyugue,
				v_hijo,
				"",
				"",
				v_tipo,
				v_nombre_cia,
				v_pre_existen,
				0.00
				with resume;

	end foreach

end foreach
--}

--{
-- Exclusiones de Dependientes

let v_tipo = 7;

let v_principal = "";

foreach
 select u.cod_cliente,
		u.cod_parentesco,
		p.no_documento,
		u.no_unidad,
		p.cod_subramo,
		u.no_activo_desde
   into _cod_asegurado,
		_cod_parentesco,
		v_no_documento,
		v_no_unidad,
		_cod_subramo,
		v_fecha_efectiva
   from emidepen u, emipomae p
  where u.no_poliza              = p.no_poliza
    and month(u.no_activo_desde) = a_periodo[6,7]
	and year(u.no_activo_desde)  = a_periodo[1,4]
	and	p.cod_ramo               = _cod_ramo
    and p.cod_subramo            in ("007", "008", "009")
    and p.actualizado            = 1

	let v_pre_existen  = 0;

	select nombre
	  into v_nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	select nombre,
	       cedula,
	       fecha_aniversario
	  into v_nombre_asegurado,
	       v_cedula,
	       v_fecha_nac
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	select tipo_pariente
	  into _tipo_parentesco
	  from emiparen
	 where cod_parentesco = _cod_parentesco;

	let v_conyugue     = "";
	let v_hijo         = "";

	if   _tipo_parentesco = 1 then
		let v_conyugue = "*";
	elif _tipo_parentesco = 2 then
		let v_hijo     = "*";
	end if					
			
	 return v_no_documento,
	        v_no_unidad,
	        v_nombre_subramo,
	        v_fecha_efectiva,
	        v_nombre_asegurado,
	        v_principal,
			v_conyugue,
			v_hijo,
			v_cedula,
			v_fecha_nac,
			v_tipo,
			v_nombre_cia,
			v_pre_existen,
			0.00
			with resume;

end foreach
--}

--{
-- Inclusion Pre-Existencias Asegurados

let v_tipo      = 8;
let v_principal = "*";
let v_conyugue  = "";
let v_hijo      = "";
let _leer_aseg  = "";

foreach	
 select	a.cod_procedimiento,
        a.fecha,
		u.cod_asegurado,
		p.no_documento,
		u.no_unidad,
		p.cod_subramo,
		u.fecha_emision
   into	_cod_procedimiento,
        v_fecha_revision,
		_cod_asegurado,
		v_no_documento,
		v_no_unidad,
		_cod_subramo,
		v_fecha_efectiva
   from	emipreas a, emipouni u, emipomae p
  where	a.no_poliza         = p.no_poliza
    and a.no_poliza         = u.no_poliza
	and a.no_unidad         = u.no_unidad
	and	p.cod_ramo          = _cod_ramo
    and p.cod_subramo       in ("007", "008", "009")
    and p.actualizado       = 1
    and month(a.date_added) = a_periodo[6,7]
	and year(a.date_added)  = a_periodo[1,4]
    and month(a.date_added) <> month(u.fecha_emision)
	and year(a.date_added)  <> year(u.fecha_emision)

	select nombre
	  into v_nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	if _leer_aseg <> _cod_asegurado then

		let v_pre_existen = 0;
		let _leer_aseg    = _cod_asegurado;

		select nombre,
		       cedula,
		       fecha_aniversario
		  into v_nombre_asegurado,
		       v_cedula,
		       v_fecha_nac
		  from cliclien
		 where cod_cliente = _cod_asegurado;

		 return v_no_documento,
		        v_no_unidad,
		        v_nombre_subramo,
		        v_fecha_efectiva,
		        v_nombre_asegurado,
		        v_principal,
				v_conyugue,
				v_hijo,
				v_cedula,
				v_fecha_nac,
				v_tipo,
				v_nombre_cia,
				v_pre_existen,
				0.00
				with resume;

	end if

	let v_pre_existen = 1;

	select nombre
	  into v_nombre_asegurado
	  from emiproce
	 where cod_procedimiento = _cod_procedimiento;

	 return v_no_documento,
	        v_no_unidad,
	        v_pre_exis_desc,
	        v_fecha_revision,
	        v_nombre_asegurado,
	        v_principal,
			v_conyugue,
			v_hijo,
			"",
			"",
			v_tipo,
			v_nombre_cia,
			v_pre_existen,
			0.00
			with resume;

end foreach
--}

--{
-- Inclusion Pre-Existencias Dependientes

let v_tipo      = 9;
let v_principal = "";
let v_conyugue  = "";
let v_hijo      = "";
let _leer_aseg  = "";

foreach	
 select	a.cod_procedimiento,
        a.fecha,
		u.cod_cliente,
		p.no_documento,
		u.no_unidad,
		p.cod_subramo,
		u.date_added,
		u.cod_parentesco,
		u.no_poliza
   into	_cod_procedimiento,
        v_fecha_revision,
		_cod_asegurado,
		v_no_documento,
		v_no_unidad,
		_cod_subramo,
		v_fecha_efectiva,
		_cod_parentesco,
		_no_poliza
   from	emiprede a, emidepen u, emipomae p
  where	a.no_poliza         = p.no_poliza
    and a.no_poliza         = u.no_poliza
	and a.no_unidad         = u.no_unidad
	and a.cod_cliente       = u.cod_cliente
	and	p.cod_ramo          = _cod_ramo
    and p.cod_subramo       in ("007", "008", "009")
    and p.actualizado       = 1
	and month(a.date_added) = a_periodo[6,7]
	and year(a.date_added)  = a_periodo[1,4]
	and month(a.date_added) <> month(u.date_added)
	and year(a.date_added)  <> year(u.date_added)
--	and p.no_documento      = "1800-00013-02"
  order by p.no_documento, u.no_unidad, u.cod_cliente

	select nombre
	  into v_nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	if _leer_aseg <> _cod_asegurado then

		let v_pre_existen = 0;
		let _leer_aseg    = _cod_asegurado;

		select tipo_pariente
		  into _tipo_parentesco
		  from emiparen
		 where cod_parentesco = _cod_parentesco;

		let v_conyugue     = "";
		let v_hijo         = "";

		if   _tipo_parentesco = 1 then
			let v_conyugue = "*";
		elif _tipo_parentesco = 2 then
			let v_hijo     = "*";
		end if					

		select nombre,
		       cedula,
		       fecha_aniversario
		  into v_nombre_asegurado,
		       v_cedula,
		       v_fecha_nac
		  from cliclien
		 where cod_cliente = _cod_asegurado;

		 return v_no_documento,
		        v_no_unidad,
		        v_nombre_subramo,
		        v_fecha_efectiva,
		        v_nombre_asegurado,
		        v_principal,
				v_conyugue,
				v_hijo,
				v_cedula,
				v_fecha_nac,
				v_tipo,
				v_nombre_cia,
				v_pre_existen,
				0.00
				with resume;

	end if

	let v_pre_existen = 1;

	select nombre
	  into v_nombre_asegurado
	  from emiproce
	 where cod_procedimiento = _cod_procedimiento;

	 return v_no_documento,
	        v_no_unidad,
	        v_pre_exis_desc,
	        v_fecha_revision,
	        v_nombre_asegurado,
	        v_principal,
			v_conyugue,
			v_hijo,
			"",
			"",
			v_tipo,
			v_nombre_cia,
			v_pre_existen,
			0.00
			with resume;

end foreach
--}
commit work;

end procedure;