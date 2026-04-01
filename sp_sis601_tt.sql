DROP PROCEDURE sp_sis601_tt;
create procedure sp_sis601_tt(a_cod_manzana char(255) default '*', a_poliza char(20) DEFAULT '*', a_estatus_poliza smallint default 1)
returning smallint, varchar(250);

define _ret_porc		  dec(9,4);
define _fac_porc		  dec(9,4);
define _exc_porc		  dec(9,4);
define _porc_partic_suma  dec(9,4);
define _porc_coas         dec(7,4);

define _no_poliza		  char(10);
define _contratante	      char(10);
define _no_unidad		  char(5);
define _fecha       	  date;
define v_asegurado		  char(100);
define _no_documento      char(20);
define v_filtros          char(255);
define _cod_manzana		  char(15);
define _suc_origen		  char(3);
define _n_suc_origen	  char(30);
define _referencia        char(50);
define _suma_asegurada    dec(16,2);
define _suma			  dec(16,2);
define _suma_ret		  dec(16,2);
define _suma_fac		  dec(16,2);
define _suma_exc		  dec(16,2);
define _actualizado       smallint;
define _tipo_incendio     smallint;
define _vig_ini           date;
define _vig_fin           date;
define _cod_ramo         char(3);
define v_cod_contrato     char(5);
define v_tipo_contrato    smallint;
define _est_pol			  smallint;
define _nombre_ag		  char(255);
define _nombre_ag_acum	  char(255);
define _cod_cober_reas	  char(3);

define _no_cambio	      smallint;
define _fecha_cancelacion date;
define _fecha_emision     date;
define _cod_coasegur      char(3);

define _prima_suscrita    dec(16,2);
define _coaseguro         varchar(25);
define _cod_tipoprod      char(3);
define _cod_ramo_uni,_cod_subramo      char(3);
define _poliza		      char(10);
define _max_retencion     decimal(16,2);
define _max_suma_asegurada     decimal(16,2);
define _mensaje           varchar(250);
define _flag	          smallint;
define _cnt	              smallint;
define _mensaje_tmp       varchar(250);

let _cnt = 0;

drop table if exists temp_sis600;	
create temp table temp_sis600 (
	no_poliza	        char(10),
	no_unidad	        char(5),
	no_documento	    char(20),
	asegurado	        char(100),  
	cod_manzana	        char(15),
	referencia	        char(50),
	sucursal_origen	    char(3),
	nombre_suc_origen	char(30),   
	suma_asegurada	    decimal(16,2),
	tipo_incendio	    smallint,
	vig_ini	            date,
	vig_fin	            date,
	tot_retencion	    decimal(16,2),
	estatus_poliza	    smallint,
	agentes_poliza	    char(100),   
	tot_facultativo	    decimal(16,2),
	tot_excedente	    decimal(16,2),
	Porc_retencion	    decimal(9,4),
	Porc_facultativo	decimal(9,4),
	Porc_excedente	    decimal(9,4),
	Prima_Suscrita	    decimal(16,2),   
	coaseguro	        varchar(25)
) with no log;

create index id1_temp_det on temp_sis600(estatus_poliza);

drop table if exists temp_sis600_msg;	
create temp table temp_sis600_msg(
	flag	        smallint,
	mensaje	        varchar(250)
) with no log;

SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

LET _cod_coasegur = sp_sis02('001','001');
--set debug file to "sp_pro845.trc";
--trace on;

let _fecha          = CURRENT;
let _suma_asegurada = 0;
let _suma_ret       = 0;

drop table if exists tmp_cober_reas;

select cod_cober_reas
  from reacobre
 where cod_ramo in ('001','003')
   and es_terremoto = 0
  into temp tmp_cober_reas;
  
 select trim(valor_parametro) 
   into _max_retencion
   from inspaag
  where codigo_compania	= '001'
    and codigo_agencia	= '001'
    and aplicacion	= 'PRO'
    and version		= '02'
    and codigo_parametro	= 'max_ret_manzana';
   
 select trim(valor_parametro) 
   into _max_suma_asegurada
   from inspaag
  where codigo_compania	= '001'
    and codigo_agencia	= '001'
    and aplicacion	= 'PRO'
    and version		= '02'
    and codigo_parametro	= 'max_suma_manzana';

if a_poliza = '*' then 
    if a_cod_manzana <> '' and a_cod_manzana <> "*" Then
		if a_estatus_poliza = 1 then -- Vigentes
		    FOREACH WITH HOLD
					select emipouni.cod_ramo,
						   emipouni.no_unidad,
						   emipouni.no_poliza,
						   emipouni.suma_asegurada,
						   emipouni.prima_suscrita,
						   cod_asegurado,
						   tipo_incendio,
						   cod_manzana,
						   emipomae.fecha_cancelacion					   
					 into  _cod_ramo_uni,
						   _no_unidad,
						   _no_poliza,
						   _suma_asegurada,
						   _prima_suscrita,
						   _contratante,
						   _tipo_incendio,
						   _cod_manzana,
						   _fecha_cancelacion
					 from emipouni, emipomae
					where emipouni.cod_manzana LIKE TRIM(a_cod_manzana) || "%"
					  and emipouni.no_poliza = emipomae.no_poliza
					  and (emipouni.cod_manzana <> '' and emipouni.cod_manzana is not null)
					  and emipomae.fecha_suscripcion <= _fecha
					  and emipomae.vigencia_inic <= _fecha
					  and emipomae.actualizado = 1
					  and emipomae.cod_ramo in ('001','003')
					order by emipouni.cod_manzana, emipouni.no_poliza, emipouni.no_unidad

					let _fecha_emision = null;

					if _fecha_cancelacion <= _fecha then
						select max(fecha_emision)
						  into _fecha_emision
						  from endedmae
						 where no_poliza = _no_poliza
						   and cod_endomov = '002'
						   and actualizado = 1;

						if  _fecha_emision <= _fecha then
							continue foreach;
						end if
					end if

					SELECT nombre
					  INTO v_asegurado
					  FROM cliclien
					 WHERE cod_cliente = _contratante;

				SELECT sucursal_origen,
					   no_documento,
					   actualizado,
					   vigencia_inic,
					   vigencia_final,
					   cod_ramo,
					   estatus_poliza, 
					   cod_tipoprod,
					   cod_subramo
				  INTO _suc_origen,
					   _no_documento,
					   _actualizado,
					   _vig_ini,
					   _vig_fin,
					   _cod_ramo,
					   _est_pol,
					   _cod_tipoprod,
					   _cod_subramo
				  FROM emipomae
				 WHERE no_poliza = _no_poliza;
				 
				if _cod_ramo = '003' and _cod_subramo = '006' then
					if _cod_ramo_uni = '001' then
					else
						continue foreach;
					end if
				end if
				-- Informacion de Coaseguro
				let _coaseguro = "";
				IF _cod_tipoprod = '001' THEN
					let _coaseguro = "COASEGURO MAYORITARIO";
					SELECT porc_partic_coas
					  INTO _porc_coas
					  FROM emicoama
					 WHERE no_poliza    = _no_poliza
					   AND cod_coasegur = _cod_coasegur;

					IF _porc_coas IS NULL THEN
						LET _porc_coas = 0;
					END IF
					
					let _suma_asegurada = _suma_asegurada * _porc_coas / 100;
					let _prima_suscrita = _prima_suscrita * _porc_coas / 100;
				ELIF _cod_tipoprod = '002' THEN
					let _coaseguro = "COASEGURO MINORITARIO";
				END IF

				SELECT descripcion
				  INTO _n_suc_origen
				  FROM insagen
				 WHERE codigo_compania = "001"
				   AND codigo_agencia  = _suc_origen;

				SELECT referencia
				  INTO _referencia
				  FROM emiman05
				 WHERE cod_manzana = _cod_manzana;

				let _suma_ret = 0;
				let _ret_porc = 0;
				let _suma_fac = 0;
				let _fac_porc = 0;
				let _suma_exc = 0;
				let	_exc_porc = 0;
				let _cod_cober_reas	= null; 
				let	_porc_partic_suma = 0;

				let _no_cambio = null;

				SELECT max(no_cambio)
				  INTO _no_cambio
				  FROM emireama
				 WHERE no_poliza      = _no_poliza
				   and no_unidad      = _no_unidad
				   and cod_cober_reas in (select cod_cober_reas from tmp_cober_reas);--= _cod_cober_reas;

				FOREACH
					SELECT cod_contrato,
						   porc_partic_suma
					  INTO v_cod_contrato,
						   _porc_partic_suma
					  FROM emireaco
					 WHERE no_poliza      = _no_poliza
					   AND no_unidad      = _no_unidad
					   AND no_cambio      = _no_cambio
					   and cod_cober_reas in (select cod_cober_reas from tmp_cober_reas)--= _cod_cober_reas;

					SELECT tipo_contrato
					  INTO v_tipo_contrato
					  FROM reacomae
					 WHERE cod_contrato = v_cod_contrato;

					IF _porc_partic_suma IS NULL THEN
						LET _porc_partic_suma = 0;
					END IF

					IF _suma_asegurada IS NULL THEN
						LET _suma_asegurada = 0;
					END IF

					IF v_tipo_contrato = 1 and _ret_porc = 0 THEN
						let _suma_ret = _suma_asegurada * _porc_partic_suma / 100;
						let _ret_porc = _porc_partic_suma;
					end if

					IF v_tipo_contrato = 3 and _fac_porc = 0 THEN
						let _suma_fac = _suma_asegurada * _porc_partic_suma / 100;
						let _fac_porc = _porc_partic_suma;
					end if

					IF v_tipo_contrato = 7 and _exc_porc = 0 THEN
						let _suma_exc = _suma_asegurada * _porc_partic_suma / 100;
						let _exc_porc = _porc_partic_suma;
					end if
				END FOREACH

				--AGENTES DE LA POLIZA
				LET _nombre_ag = "";
				LET _nombre_ag_acum = "";

				FOREACH
					SELECT TRIM(agtagent.nombre)
					  INTO _nombre_ag
					  FROM agtagent, emipoagt 
					 WHERE emipoagt.cod_agente = agtagent.cod_agente
					   AND emipoagt.no_poliza  = _no_poliza

					LET _nombre_ag_acum = trim(_nombre_ag_acum) || " " || trim(_nombre_ag) ;
				END FOREACH

				insert into temp_sis600
				values( _no_poliza, _no_unidad, _no_documento, v_asegurado, _cod_manzana,_referencia, _suc_origen,_n_suc_origen,_suma_asegurada,_tipo_incendio,
						_vig_ini,_vig_fin,_suma_ret, _est_pol, _nombre_ag_acum,_suma_fac,_suma_exc,_ret_porc,_fac_porc,_exc_porc,_prima_suscrita, _coaseguro);	
				
	        END FOREACH
		end if	
    End if
end if

--ParÃ¡metro para el mensaje de Advertencia (por superar o superado los 500k)
let _suma_ret = 0;
let _flag = 0;
let _mensaje = '';
select sum(suma_asegurada)
  into _suma_ret
  from temp_sis600
 where estatus_poliza = a_estatus_poliza;

if _suma_ret > _max_suma_asegurada then  
    let _flag = 1; 	
	let _mensaje = 'SUMA ASEGURADA EXCEDE LOS B/. 13,000,000.00 DEL TOPE DE CUMULO, FAVOR REVISE.';
	insert into temp_sis600_msg values(_flag,_mensaje);	
end if

let _suma_ret = 0;
if _flag = 0 or _flag = 1 then
	select sum(tot_retencion)
	  into _suma_ret
	  from temp_sis600
	 where estatus_poliza = a_estatus_poliza;
	   
	if _suma_ret > _max_retencion then 
		let _flag = 2; 
		let _mensaje = 'MANZANA SELECCIONADA SUPERA EL TOPE DEL CONTRATO DE RETENCION B/. 500,000.00. FAVOR VERIFIQUE.';
		insert into temp_sis600_msg	values(_flag,_mensaje);		
	end if
end if

if _flag = 1 then
	let _mensaje = 'SUMA ASEGURADA EXCEDE LOS B/. 500,000.00 DE RETENCION. FAVOR VERIFIQUE.';
end if
if _flag = 2 then
	let _mensaje = 'MANZANA SELECCIONADA SUPERA EL TOPE DEL CONTRATO DE RETENCION B/. 500,000.00 FAVOR VERIFIQUE.';
end if
let _cnt = 0;

select count(*) 
  into _cnt
  from temp_sis600_msg;

if _cnt = 0 then   
	RETURN _flag,_mensaje;
else
    let _mensaje = '';
	foreach
		select flag,trim(mensaje)
			into _flag,_mensaje_tmp
			from temp_sis600_msg
			
		let _mensaje = _mensaje||trim(_mensaje_tmp)||'                                                                  ';
	end foreach
	RETURN _flag,_mensaje;
end if
drop table temp_sis600;
drop table temp_sis600_msg;
end procedure