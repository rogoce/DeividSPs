--*****************************************************************
-- Procedimiento que Genera TXT - VOCEM
--*****************************************************************
-- Execute procedure sp_cob412("001","001","2017-05","HGIRON")
-- Creado    : 26/06/2018      -- Autor: Henry Giron

DROP PROCEDURE sp_cob412;
CREATE PROCEDURE sp_cob412(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo char(7),a_usuario CHAR(8))
RETURNING VARCHAR(20)	as	no_documento	,
		VARCHAR(10)	as	vigencia_inic	,
		VARCHAR(10)	as	vigencia_fin	,
		VARCHAR(16)	as	exigible	,
		VARCHAR(16)	as	por_vencer	,
		VARCHAR(16)	as	corriente	,
		VARCHAR(16)	as	monto_30	,
		VARCHAR(16)	as	monto_60	,
		VARCHAR(16)	as	monto_90	,
		VARCHAR(10)	as	fecha_cubierto	,
		VARCHAR(10)	as	fecha_suspension	,
		VARCHAR(20)	as	cedula	,
		VARCHAR(60)	as	nombre	,
		VARCHAR(10)	as	telefono9	,
		VARCHAR(10)	as	telefono2	,
		VARCHAR(50)	as	e_mail	,
		VARCHAR(150)	as	direccion_1	,
		VARCHAR(150)	as	direccion_2	,
		VARCHAR(10)	as	tipo_persona	;			


define _nombre          char(50);
DEFINE _fecha_actual	date;
DEFINE _mes_char		char(2);
DEFINE _ano_char		char(4);
DEFINE _periodo_c		char(7);
define _no_documento      char(20); 
define _no_poliza       char(10);
define _cod_contratante	  char(10);
define _vig_inic          date;      
define _vig_final         date;      
define _exigible		  dec(16,2);
define _por_vencer        dec(16,2);
define _corriente         dec(16,2);
define _monto_30		  dec(16,2);
define _monto_60		  dec(16,2);
define _monto_90		  dec(16,2);
define _saldo			  dec(16,2);   
define _fecha_cubierto    date;      
define _fecha_suspension  date;      	
define _cedula            char(30);	 
define _nombre_aseg	      char(50); 
define _telefono1         VARCHAR(10);
define _telefono2         VARCHAR(10);
define _telefono9         VARCHAR(10);
define _e_mail			  VARCHAR(50);
define _direccion_1		  VARCHAR(150);
define _direccion_2		  VARCHAR(150);
Define _tipo_persona	  char(1);
define _vigencia_inic	date;
define _vigencia_fin	date;
define _fecha_hoy		date;

define _t_no_documento	  VARCHAR(20);
define _t_vigencia_inic   VARCHAR(10);
define _t_vigencia_fin    VARCHAR(10);
define _t_exigible	      VARCHAR(16);
define _t_por_vencer	  VARCHAR(16);
define _t_corriente	      VARCHAR(16);
define _t_monto_30	      VARCHAR(16);
define _t_monto_60	      VARCHAR(16);
define _t_monto_90	      VARCHAR(16);
define _t_fecha_cubierto	 VARCHAR(10);
define _t_fecha_suspension   VARCHAR(10);
define _t_cedula	         VARCHAR(20);
define _t_nombre	         VARCHAR(60);
define _t_telefono9	         VARCHAR(10);
define _t_telefono2	         VARCHAR(10);
define _t_e_mail	         VARCHAR(50);
define _t_direccion_1	     VARCHAR(150);
define _t_direccion_2	     VARCHAR(150);
define _t_tipo_persona       VARCHAR(10) ;


--SET DEBUG FILE TO "sp_cob412.trc";
--TRACE ON;



let _fecha_actual = sp_sis26() ;
IF MONTH(_fecha_actual) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_actual);
ELSE
	LET _mes_char = MONTH(_fecha_actual);
END IF

LET _ano_char = YEAR(_fecha_actual);
LET _periodo_c  = _ano_char || "-" || _mes_char;

drop table if exists temp_data1;
CREATE TEMP TABLE temp_data1(
	no_documento	 VARCHAR(20),
	vigencia_inic    VARCHAR(10),
	vigencia_fin     VARCHAR(10),
	exigible	     VARCHAR(16),
	por_vencer	     VARCHAR(16),
	corriente	     VARCHAR(16),
	monto_30	     VARCHAR(16),
	monto_60	     VARCHAR(16),
	monto_90	     VARCHAR(16),
	fecha_cubierto	 VARCHAR(10),
	fecha_suspension VARCHAR(10),
	cedula	         VARCHAR(20),
	nombre	         VARCHAR(60),
	telefono9	     VARCHAR(10),
	telefono2	     VARCHAR(10),
	e_mail	         VARCHAR(50),
	direccion_1	     VARCHAR(150),
	direccion_2	     VARCHAR(150),
	tipo_persona     VARCHAR(10) )
WITH NO LOG;
CREATE INDEX idx1_temp_data1 ON temp_data1(no_documento,cedula,tipo_persona);


SET ISOLATION TO DIRTY READ;
--*************************************************
-- Polizas Vigentes Automovil sin Flotas asociadas
--*************************************************
-- Forma de Pago ANC y ACH   -- 006,005 cobforpa 
-- Vigentes                  -- 1 emipomae
-- Ramo principal de AUTOMOVIL y SODA (excluye FOTAS) y todas las pólizas vigentes asociadas a estos clientes -- 002 y 020
-- Exclusiones
--     Grupos de talleres (tengo que conseguirte los codigos)
--     Grupo Scotiabank
--     Grupo Banisi
--     Coaseguro mayoritario y minoritario
--     Fronting
--     Gobiernos



foreach
	select e.no_documento,
			e.no_poliza, 			
			e.cod_contratante,
			e.vigencia_inic,
			e.vigencia_final
	   into _no_documento,
			_no_poliza,		
			_cod_contratante,
			_vig_inic,
			_vig_final
	  from emipomae e	  
	where  e.actualizado = 1
	   and e.estatus_poliza = 1	   
	   and e.periodo  = a_periodo
	   and (e.cod_ramo in ('002','020')	and e.cod_ramo not in ('023') )     
	   and e.cod_formapag in ('006','005')                        -- Solo: ANC y ACH 
	   and e.cod_grupo not in ('1090','124','125','00000','1000') -- Excluye: Grupo Scotiabank, Banisi y Gobierno
	   and e.fronting = 0                                         -- Excluye: Fronting
	   and e.cod_tipoprod not in ("001","002")                    -- Excluye: Coaseguro mayoritario y minoritario
	   

	    
		call sp_cob33('001','001', _no_documento, _periodo_c, _fecha_actual)
		returning   _por_vencer,
					_exigible,
					_corriente,
					_monto_30,
					_monto_60,
					_monto_90,
					_saldo;	
		  
	  
		 select nombre,		        
				cedula,			
				telefono1,
				celular, 
				e_mail, 
				direccion_1, 
				direccion_2,
				tipo_persona
		   into _nombre,		        
				_cedula,			
				_telefono9,
				_telefono2, 
				_e_mail, 
				_direccion_1, 
				_direccion_2,
                _tipo_persona				
		   from cliclien 
		  where cod_cliente = _cod_contratante;	  
		  
		 select fecha_cubierto,
				fecha_suspension
		   into _fecha_cubierto,
				_fecha_suspension			
		   from emipoliza
		  where no_documento = _no_documento;
	 
	
		BEGIN
			ON EXCEPTION IN(-239,-268) 
			END EXCEPTION 

			Insert into temp_data1 (
			no_documento,
			vigencia_inic,
			vigencia_fin,
			exigible,
			por_vencer,
			corriente,
			monto_30,
			monto_60,
			monto_90,
			fecha_cubierto,
			fecha_suspension,
			cedula,
			nombre,
			telefono9,
			telefono2,
			e_mail,
			direccion_1,
			direccion_2,
			tipo_persona) 
			values (					
			_no_documento,
			_vig_inic,
			_vig_final,
			_exigible,
			_por_vencer,
			_corriente,
			_monto_30,
			_monto_60,
			_monto_90,
			_fecha_cubierto,
			_fecha_suspension,
			_cedula,
			_nombre,
			_telefono9,
			_telefono2,
			_e_mail,
			_direccion_1,
			_direccion_2,
			_tipo_persona); 							
		END					
		
	
end foreach



foreach
	select 
			no_documento,
			vigencia_inic,
			vigencia_fin,
			exigible,
			por_vencer,
			corriente,
			monto_30,
			monto_60,
			monto_90,
			fecha_cubierto,
			fecha_suspension,
			cedula,
			nombre,
			telefono9,
			telefono2,
			e_mail,
			direccion_1,
			direccion_2,
			tipo_persona			
	  into _t_no_documento,
			_t_vigencia_inic,
			_t_vigencia_fin,
			_t_exigible,
			_t_por_vencer,
			_t_corriente,
			_t_monto_30,
			_t_monto_60,
			_t_monto_90,
			_t_fecha_cubierto,
			_t_fecha_suspension,
			_t_cedula,
			_t_nombre,
			_t_telefono9,
			_t_telefono2,
			_t_e_mail,
			_t_direccion_1,
			_t_direccion_2,
			_t_tipo_persona
	  from temp_data1 
	   

return _t_no_documento,
			_t_vigencia_inic,
			_t_vigencia_fin,
			_t_exigible,
			_t_por_vencer,
			_t_corriente,
			_t_monto_30,
			_t_monto_60,
			_t_monto_90,
			_t_fecha_cubierto,
			_t_fecha_suspension,
			_t_cedula,
			_t_nombre,
			_t_telefono9,
			_t_telefono2,
			_t_e_mail,
			_t_direccion_1,
			_t_direccion_2,
			_t_tipo_persona 
			with resume;	

  
end foreach




END PROCEDURE;