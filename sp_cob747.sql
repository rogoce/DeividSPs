-- Proceso de Aviso de Cancelación Automático
-- Creado  : 13/07/2010 -- Autor: Henry Girón
drop procedure sp_cob747;
create procedure "informix".sp_cob747(a_user_proceso CHAR(15))
RETURNING SMALLINT,
          char(100),
		  char(10);

define _no_documento	char(20);
define _no_poliza       char(10);
define _cod_ramo        char(3);  
define _nombre_ramo     char(50);  
define _cod_grupo       char(5);
define _nombre_subramo	char(50);  
define _cod_pagador		char(10);
define _cod_contratante	char(10);
define _cod_tipoprod	char(3);
define _cod_agencia		char(3);
define _cod_subramo		char(3);
define _cedula   		char(30);
define _nombre_cliente	varchar(100);
define _no_aviso		char(10);
define _periodo			char(7);
define _saldo			dec(16,2);
define _por_vencer		dec(16,2);
define _exigible		dec(16,2);
define _corriente		dec(16,2);
define _dias_30			dec(16,2);
define _dias_60			dec(16,2);
define _dias_90			dec(16,2);
define _dias_120		dec(16,2);
define _dias_150		dec(16,2);
define _dias_180		dec(16,2);
define _cod_acreedor    char(10);   --11/03/2019HG:char(5);
define _nombre_acreedor	char(50);
define _cod_agente      char(5);
define _nombre_agente	char(50);
define _porcentaje      dec(16,2);
define _telefono        char(10);
define _cod_cobrador    char(3);
define _cod_vendedor    char(3);
define _apartado        char(20);
define _vigencia_inic   date;
define _vigencia_final	date;
DEFINE _estatus_poliza  char(1); 
define _referencia      char(10);
define _hay 			integer;
define _periodo_ult     char(7);
define _error 			smallint;
define _error_isam		smallint;
define _error_desc		char(100);
define _secuencia       integer;
define _largo			integer;
define _i				integer;
define _relleno         char(5);
define _tiene_email		smallint;
define _tiene_apart		smallint;
define _tiene_acree		smallint;

define _fax_cli         char(10);
define _tel1_cli        char(10);
define _tel2_cli        char(10);
define _fecha_hoy     	DATE;
define _apart_cli       char(20);
define _email_cli       char(50);
define _apart_agt       char(20);
define _email_agt       char(50);
define _apart_acre      char(20);
define _email_acre      char(50);

DEFINE _cod_formapag    CHAR(3);
DEFINE _nombre_formapag CHAR(50);
DEFINE _cobra_poliza    CHAR(1);
DEFINE _prima_orig      DEC(16,2);
DEFINE _prima_orig_tot  DEC(16,2);
DEFINE _estatus			CHAR(1);

DEFINE _user_proceso    CHAR(15);
DEFINE _fecha_proceso	DATE;
DEFINE _fecha_vence		DATE;
DEFINE _ano,_leasing	Smallint;
DEFINE _cod_ase         char(10);

--drop table tmp_dif;
SET ISOLATION TO DIRTY READ;
begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc, _error_isam;
end exception

let _no_aviso = null;
let _fecha_hoy = sp_sis26();
let _user_proceso = a_user_proceso;
let _leasing      = 0;

-- SET DEBUG FILE TO "sp_cob747.trc";
-- TRACE ON;

-- Estatus
-- G - Proceso
-- R - Clasificar (Email,Apartado,Otros)
-- I - Imprimir	y Enviar
--X M - Marcar Aviso
--X E - Marcar Conservacion
-- X - Procesar a Quince dias
-- Y - Desmarcar Poliza x Pagos
-- Z - Cancelar	Poliza

-- CLASE
-- 1 - Email
-- 2 - Apartado
-- 3 - Otros

SELECT valor_parametro
  INTO _secuencia    
  FROM parcont
 WHERE cod_compania    = "001"
   AND aplicacion      = "COB"
   AND version         = "02"
   AND cod_parametro   =  "par_aviso_canc" ;

LET _referencia  = '00000';

IF _secuencia > 9999 THEN
	LET _referencia = _secuencia;
ELIF _secuencia > 999 THEN
	LET _referencia[2,5] = _secuencia;
ELIF _secuencia > 99  THEN
	LET _referencia[3,5] = _secuencia;
ELIF _secuencia > 9  THEN
	LET _referencia[4,5] = _secuencia;
ELSE
	LET _referencia[5,5] = _secuencia;
END IF
 
if _referencia IS NOT NULL or _secuencia <> 0 then
	-- En avisocan en la referencia esta el ultimo mes cerrado
	let _periodo_ult = ""; 
	FOREACH 
		select distinct periodo 
		  into _periodo_ult 
		  from avisocanc 
		 where no_aviso = _referencia 
		 order by periodo desc 

		 exit foreach; 
	END FOREACH 

	if _periodo_ult IS NOT NULL then
		let _hay = 0;

		-- Este ultimo periodo se valida con lo que tiene cobmoros
		select count(*)
		  into _hay
		  from cobmoros
		 where periodo = _periodo_ult;
		
		if _hay <> 0 then
			return 1, 'Periodo No Valido, Avisos de Cancelacion una vez al mes...',_periodo_ult;
		end if
	end if	
end if		 		

-- una vez pase la validacion verifica cobmoros 
-- siguiendo las condiciones que sea _estatus_poliza: = 1, ramo: 018 > 30 los demas > 90

foreach 
	 select no_poliza,
			no_documento,
			periodo,
			saldo,
			por_vencer,
			exigible,
			corriente,
			dias_30,
			dias_60,
			dias_90,
			dias_120,
			dias_150,
			dias_180			
	   into _no_poliza,
			_no_documento,
			_periodo,
			_saldo,
			_por_vencer,
			_exigible,
			_corriente,
			_dias_30,
			_dias_60,
			_dias_90,
			_dias_120,
			_dias_150,
			_dias_180
	   from deivid_cob:cobmoros
      WHERE saldo > 0

	 select estatus_poliza,
	        cod_grupo, 
	        cod_ramo, 
	        cod_pagador, 
	        cod_contratante, 
	        cod_tipoprod,
			sucursal_origen,
			cod_subramo,
		   	vigencia_inic,
		    vigencia_final,
			cod_formapag,
			cobra_poliza,
		    prima_bruta,
			leasing
	   into _estatus_poliza,
	        _cod_grupo,
	        _cod_ramo,
	        _cod_pagador,
	        _cod_contratante,
	        _cod_tipoprod,
			_cod_agencia,
			_cod_subramo,
		   	_vigencia_inic,
		    _vigencia_final,
			_cod_formapag,
			_cobra_poliza,
			_prima_orig_tot,
			_leasing
	   from emipomae
      where no_poliza   = _no_poliza
        and actualizado = 1;

	  SELECT nombre
	    INTO _nombre_formapag
	    FROM cobforpa
	   WHERE cod_formapag = _cod_formapag;     

		 -- Polizas vigentes solamente
		  if _estatus_poliza <> 1 then
			 continue foreach;
		 end if

		  if _dias_30 is null then
		     let _dias_30 = 0;
		 end if

		  if _dias_60 is null then
		     let _dias_60 = 0;
		 end if

		  if _dias_90 is null then
		     let _dias_90 = 0;
		 end if

		  if _dias_120 is null then
		     let _dias_120 = 0;
		 end if

		  if _dias_150 is null then
		     let _dias_150 = 0;
		 end if

		  if _dias_180 is null then 
		     let _dias_180 = 0; 
		 end if 

		 -- Para salud la morosidad es a 31 dias y para los demas a 91 dias 
		 if _cod_ramo in ("018")  then 
			let _saldo = _dias_30 +	_dias_60 +  _dias_90 + _dias_120 + _dias_150 + _dias_180; 
		else 
			let _saldo = _dias_60 + _dias_90 + _dias_120 + _dias_150 + _dias_180; 
	    end if 
	    
		 if _saldo = 0  then  
			continue foreach; 
		end if 

		let _apart_cli  = " "; 
		let _email_cli  = " ";  
		let _apart_agt  = " ";  
		let _email_agt  = " "; 
		  	    	
		 if _no_aviso is null then
			-- crea y actualiza el contador 
			let _no_aviso = sp_sis13("001", "COB", "02", "par_aviso_canc");  -- Crear en parcont
		end if

	 -- Datos del cliente de la poliza
	 select cedula,
	        nombre,
			trim(fax),
			telefono1,
			telefono2,
			apartado,
			e_mail
	   into _cedula,
	        _nombre_cliente,
			_fax_cli,
			_tel1_cli,
			_tel2_cli,
			_apart_cli,
			_email_cli
	   from cliclien
	  where cod_cliente = _cod_contratante;

	    let _cod_acreedor = null;

		foreach
		 select	cod_acreedor
		   into	_cod_acreedor
		   from emipoacr
		  where	no_poliza = _no_poliza

			 if _cod_acreedor is not null then

				select nombre
				  into _nombre_acreedor
				  from emiacre
				 where cod_acreedor = _cod_acreedor;

				exit foreach;
			end if
		end foreach

		-- Datos del acreedor de la poliza
		if _cod_acreedor is null then
		   if _leasing = 1 then	--La poliza es leasing
				foreach
					select cod_asegurado
					  into _cod_ase
					  from emipouni
					 where no_poliza = _no_poliza
					
					select nombre
					  into _nombre_acreedor
					  from cliclien
					 where cod_cliente = _cod_ase;
					 
					let _cod_acreedor = _cod_ase;  
				end foreach
		   else
			LET _cod_acreedor = '';
			LET _nombre_acreedor = '... SIN ACREEDOR ...';
		   end if	
		end if

		foreach 
		 select	cod_agente,
				porc_partic_agt
		   into	_cod_agente,
				_porcentaje
		   from emipoagt
		  where	no_poliza = _no_poliza

		 -- Prima 
		   LET _prima_orig = _prima_orig_tot / 100 * _porcentaje;

		   if _prima_orig is null then
		    	let _prima_orig = 0.00;
		  end if
		-- Datos del acreedor de la poliza

				select nombre,
					   telefono1,
					   cod_cobrador,
					   cod_vendedor,
					   apartado,
					   e_mail
				  into _nombre_agente,
					   _telefono,
					   _cod_cobrador,
					   _cod_vendedor,
					   _apart_agt,
					   _email_agt
				  from agtagent
				 where cod_agente = _cod_agente;

			    select nombre
				  into _nombre_ramo
			      from prdramo
				 where cod_ramo = _cod_ramo;

				select nombre 
				  into _nombre_subramo 
			      from prdsubra 
				 where cod_ramo    = _cod_ramo 
				   and cod_subramo = _cod_subramo; 

		           --  Fechas de Procesos 
				   LET _fecha_proceso = _fecha_hoy ; 
				   LET _fecha_vence   = _fecha_proceso + 15 ; 
				   LET _ano           =	YEAR(_vigencia_inic); 
				   				  
				   --  Estatus
				   LET _estatus = "G" ;	  -- Estatus: Generar Data
{
					if (_cod_grupo = '00068' and _cod_contratante = '699702') or  (_cod_grupo = '00068' and trim(_cedula) = '3-NT-1-690') or  (_cod_grupo = '00068' and trim(_cedula) = '3-1-6906') then --Serafin Niño  CASO SD#5362:RGORDON:10/01/2023_: Ajustes en Proceso de Aviso de Cancelación para Cartera de Serafin Niño
						foreach
								select uni.cod_asegurado
								  into _cod_contratante
								  from emipouni uni
								 inner join cliclien cli on cli.cod_cliente = uni.cod_asegurado
								 where no_poliza = _no_poliza
								  -- and no_unidad = '00001'
								  
								-- Datos del cliente de la poliza cuando es serafin toma el primer asegurado de la unidad
								select cedula,
									   nombre,
									   apartado,					   
									   telefono2,					   					   
									   telefono1							   
								  into _cedula,
									   _nombre_cliente,	
									   _apart_cli,					   					   
									   _tel2_cli,
									   _tel1_cli					   
								  from cliclien
								 where cod_cliente = _cod_contratante;	
								 
									let _email_cli = 'gerencia@serafinnino.com.pa';
									
								   exit foreach;
							   
						end foreach
					end if	
}	

					if (_cod_grupo = '00068' or _cod_grupo = '77978' ) then --CASO SD#6889:JEPEREZ:Proximo Tiraje: Ajustes en Proceso de Aviso de Cancelación para Cartera de Serafin Niño solo a grupos :  00068  SERAFIN NIÑO o 77978  ASOCIADOS SERAFIN NIÑO
							let _email_cli = 'gerencia@serafinnino.com.pa';
					end if					

				 insert into avisocanc
					    (no_aviso,
					    no_documento, 
					    no_poliza,
					    periodo,
					   	vigencia_inic,
					    vigencia_final,
					    cod_ramo,
						nombre_ramo,
						nombre_subramo,
					    cedula,
					    nombre_cliente,
					    saldo,
					    por_vencer,
					    exigible,
					    corriente,
					    dias_30,
					    dias_60,
					    dias_90,
					    dias_120,
					    dias_150,
					    dias_180,
					    cod_acreedor,
					    nombre_acreedor,
						cod_agente,							    
						nombre_agente,					    
						porcentaje,							    
						telefono,							    
						cod_cobrador,						    
						cod_vendedor,						    
						apartado,
						fax_cli,
						tel1_cli,
						tel2_cli,
						apart_cli,
						email_cli,
						cod_formapag,   
						nombre_formapag,
						cobra_poliza,
						cod_contratante,
						estatus,
						user_proceso,
						fecha_proceso,
						fecha_vence,
						prima,
						ano								 					       		    
					     )
				 values (_no_aviso,
					    _no_documento,
					    _no_poliza,
					    _periodo,
					   	_vigencia_inic,
					    _vigencia_final,
					    _cod_ramo,
						_nombre_ramo,
						_nombre_subramo,
					    _cedula,
					    _nombre_cliente,
					    _saldo,
					    _por_vencer,
					    _exigible,
					    _corriente,
					    _dias_30,
					    _dias_60,
					    _dias_90,
					    _dias_120,
					    _dias_150,
					    _dias_180,
					    _cod_acreedor,
					    _nombre_acreedor,   	
						_cod_agente,							    
						_nombre_agente,					    
						_porcentaje,							    
						_telefono,							    
						_cod_cobrador,						    
						_cod_vendedor,						    
						_apart_agt,
						_fax_cli,
						_tel1_cli,
						_tel2_cli,
						_apart_cli,
						_email_cli,
						_cod_formapag,  
					    _nombre_formapag,
					    _cobra_poliza,
					    _cod_contratante,
						_estatus,
						_user_proceso,
						_fecha_proceso,
						_fecha_vence,
						_prima_orig,
						_ano 
					    );

		end foreach

end foreach

end 

--TRACE Off;
return 0, 'Proceso Realizado con Exito...',_no_aviso;

end procedure				  			 


   










