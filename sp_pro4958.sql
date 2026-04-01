-- sp_pro4958 Insertando tabla temporal datos de reportes sp_pro4953, sp_pro4954 y sp_pro4956
-- Creado    : 21/08/2015 - Autor: Henry Girón
-- Modificado: 25/08/2015 - Autor: Henry Girón
-- SIS v.2.0 -  - DEIVID, S.A.
-- execute procedure sp_pro4958('2016-07')

drop procedure sp_pro4958;
Create procedure sp_pro4958(a_periodo char(7))		
returning	varchar(100),
			varchar(50),
			varchar(50),
			char(10),
			char(10),
			char(10),
			char(20),
			char(3),
			char(3),
			char(3),
			date,
			varchar(50),
			char(5),
			dec(16,2),
			char(7),
			varchar(100),
			dec(16,2),
			dec(16,2),
			char(100),
			dec(16,2),
			char(100),
			varchar(20), 
			char(1), 
			char(1);			
			

define _error_desc			varchar(255);
define _nom_cober_reas		varchar(50);
define _nom_contrato		varchar(50);
define _nom_coasegur		varchar(50);
define _estatus				varchar(10);
--define _no_documento		char(21);
--define _no_poliza			char(10);
define _cod_contrato		char(5);
define _cod_cober_reas		char(3);
define _cod_coasegur		char(3);
define _cod_ramo			char(3);
define _impuesto_coasegur	dec(16,2);
define _porc_partic_reas	dec(16,2);
define _comis_coasegur		dec(16,2);
define _saldo_reaseg		dec(16,2);
define _saldo_neto			dec(16,2);
define _saldo_255			dec(16,2);
define _porc_cont_partic	dec(9,6); 
define _porc_comision		dec(5,2); 
define _estatus_poliza		smallint;
define _serie				smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_cancelacion	date;
define _vigencia_final		date;
define _vigencia_inic		date;


define _nombre_zona		varchar(50);
define _nombre_cliente	varchar(100);
define _deducible_txt	char(100);
define _name_cliclien	varchar(100);
define _nombre_plan     char(100);
define _direccion		varchar(50);
define _direccion2		varchar(50);
define _nombre_agente	varchar(50);
define _no_documento	char(20);
define _deducible_din	char(18);
define _telefono1		char(10);
define _telefono2		char(10);
define _no_poliza		char(10);
define _celular      	char(10);
define _periodo			char(7);
define _cod_producto	char(5);
define _cod_agente		char(5);
define _cod_vendedor	char(3);
define _cod_formapag	char(3);
define _cod_subramo		char(3);
define _cod_perpago		char(3);
define _deducible_int	dec(16,2);
define _deducible		dec(16,2);
define _co_pago			dec(16,2);
define _prima			dec(16,2);
define _fecha_aniv		date;
DEFINE _ls_autoriza     CHAR(20);
define _fecha_desde     date;
define _fecha_hasta     date;
define _listado         char(1);
define _seleccionado    char(1);

set isolation to dirty read;

{on exception set _error,_error_isam,_error_desc
	return '','','','01/01/1900','01/01/1900','','','','','',current,'','',0.00,'',_error_desc,0.00,0.00,'',0.00,'','','';
end exception}			

drop table if exists temp_carta2016;
--set debug file to "sp_pro4958.trc";
--trace on;
let _listado = '';
     create temp table temp_carta2016
			  (nombre_cliente	char(100), 
			   direccion    	varchar(50), 
			   direccion2    	varchar(50), 
			   telefono1    	char(10),	
			   telefono2    	char(10),	
			   celular      	char(10),	
			   no_documento		char(20),	
			   cod_subramo  	char(3),	
			   cod_formapag 	char(3),	
			   cod_perpago  	char(3),	
			   fecha_aniv   	date,	
			   nombre_agente	char(50),	
			   cod_producto 	char(5), 
			   prima      		decimal(16,2),
			   periodo    		char(7), 
			   name_cliclien    char(100),
			   deducible		dec(16,2),	
			   co_pago  		dec(16,2),	
			   nombre_plan      char(100),
			   deducible_int	dec(16,2),
			   deducible_txt    char(100),
			   zona             varchar(50),
			   listado          char(1), -- 'A'
			   seleccionado     char(1)
            ) with no log;
										 
	create index idx1_temp_carta2016 on temp_carta2016(no_documento);
	create index idx2_temp_carta2016 on temp_carta2016(cod_subramo);
	create index idx3_temp_carta2016 on temp_carta2016(periodo);
	create index idx4_temp_carta2016 on temp_carta2016(zona);

	
FOREACH EXECUTE PROCEDURE sp_pro4953b(a_periodo,0,1,0,1,2,3,'%') 
           INTO _nombre_cliente,
				_direccion, 
				_direccion2,
				_telefono1, 
				_telefono2, 
				_celular, 
				_no_documento, 
				_cod_subramo, 
				_cod_formapag, 
				_cod_perpago, 
				_fecha_aniv, 
				_nombre_agente, 
				_cod_producto, 
				_prima, 
				_periodo, 
				_name_cliclien,
				_deducible,		
				_co_pago,  		
				_nombre_plan,
				_deducible_int,
				_deducible_txt,
				_nombre_zona
		INSERT INTO temp_carta2016 
		VALUES (_nombre_cliente,
				_direccion, 
				_direccion2,
				_telefono1, 
				_telefono2, 
				_celular, 
				_no_documento, 
				_cod_subramo, 
				_cod_formapag, 
				_cod_perpago, 
				_fecha_aniv, 
				_nombre_agente, 
				_cod_producto, 
				_prima, 
				_periodo, 
				_name_cliclien,
				_deducible,		
				_co_pago,  		
				_nombre_plan,
				_deducible_int,
				_deducible_txt,
				_nombre_zona,'A','0');
END FOREACH;

FOREACH EXECUTE PROCEDURE sp_pro4954b(a_periodo,0,1,0,1,2,3,'%') 
           INTO _nombre_cliente,
				_direccion, 
				_direccion2,
				_telefono1, 
				_telefono2, 
				_celular, 
				_no_documento, 
				_cod_subramo, 
				_cod_formapag, 
				_cod_perpago, 
				_fecha_aniv, 
				_nombre_agente, 
				_cod_producto, 
				_prima, 
				_periodo, 
				_name_cliclien,
				_deducible,		
				_co_pago,  		
				_nombre_plan,
				_deducible_int,
				_deducible_txt,
				_nombre_zona
		INSERT INTO temp_carta2016 
		VALUES (_nombre_cliente,
				_direccion, 
				_direccion2,
				_telefono1, 
				_telefono2, 
				_celular, 
				_no_documento, 
				_cod_subramo, 
				_cod_formapag, 
				_cod_perpago, 
				_fecha_aniv, 
				_nombre_agente, 
				_cod_producto, 
				_prima, 
				_periodo, 
				_name_cliclien,
				_deducible,		
				_co_pago,  		
				_nombre_plan,
				_deducible_int,
				_deducible_txt,
				_nombre_zona,'B','0');
END FOREACH;

FOREACH EXECUTE PROCEDURE sp_pro4956b(a_periodo,0,1,0,1,2,3,'%') 
           INTO _nombre_cliente,
				_direccion, 
				_direccion2,
				_telefono1, 
				_telefono2, 
				_celular, 
				_no_documento, 
				_cod_subramo, 
				_cod_formapag, 
				_cod_perpago, 
				_fecha_aniv, 
				_nombre_agente, 
				_cod_producto, 
				_prima, 
				_periodo, 
				_name_cliclien,
				_deducible,		
				_co_pago,  		
				_nombre_plan,
				_deducible_int,
				_deducible_txt,
				_nombre_zona
		INSERT INTO temp_carta2016 
		VALUES (_nombre_cliente,
				_direccion, 
				_direccion2,
				_telefono1, 
				_telefono2, 
				_celular, 
				_no_documento, 
				_cod_subramo, 
				_cod_formapag, 
				_cod_perpago, 
				_fecha_aniv, 
				_nombre_agente, 
				_cod_producto, 
				_prima, 
				_periodo, 
				_name_cliclien,
				_deducible,		
				_co_pago,  		
				_nombre_plan,
				_deducible_int,
				_deducible_txt,
				_nombre_zona,'C','0');
END FOREACH;
	
-- Busca Firma

SELECT valor_parametro 
  INTO _ls_autoriza
  FROM inspaag
 WHERE codigo_parametro = "firma_carta_salud"
   AND codigo_agencia   = '001';

foreach
     select nombre_cliente,
			direccion,
            direccion2,			
			telefono1,    	
			telefono2,    	
			celular,      	
			no_documento,	
			cod_subramo, 	
			cod_formapag, 	
			cod_perpago,	
			fecha_aniv,	
			nombre_agente,	
			cod_producto,	
			prima,	
			periodo,	
			name_cliclien,
	  	  	deducible,		
	  	  	co_pago,  		
	  	  	nombre_plan,
	  	  	deducible_int,
	  	  	deducible_txt,
	  	  	zona,
            listado,
			seleccionado			
       into _nombre_cliente,
			_direccion, 
			_direccion2,
			_telefono1, 
			_telefono2, 
			_celular, 
	        _no_documento, 
			_cod_subramo, 
			_cod_formapag, 
			_cod_perpago, 
			_fecha_aniv, 
			_nombre_agente, 
			_cod_producto, 
			_prima, 
			_periodo, 
			_name_cliclien,
	  	  	_deducible,		
	  	  	_co_pago,  		
	  	  	_nombre_plan,
	  	  	_deducible_int,
	  	  	_deducible_txt,
			_nombre_zona,
			_listado,
			_seleccionado
       from temp_carta2016	
	  order by nombre_agente asc, zona, no_documento asc   

	         return trim(_nombre_cliente),	--01
					trim(_direccion),		--02
					trim(_direccion2),
					_telefono1,			--03
					_telefono2,			--04
					_celular,			--05
			        _no_documento,		--06
					_cod_subramo,		--07
					_cod_formapag,		--08
					_cod_perpago,		--09
					_fecha_aniv,		--10
					trim(_nombre_agente),		--11
					_cod_producto,		--12
					_prima,				--13
					_periodo,			--14
					trim(_name_cliclien),		--15
			  	  	_deducible,			--16		
			  	  	_co_pago,			--17  		
			  	  	_nombre_plan,		--18
					_deducible_int,		--19
					_deducible_txt,		--20
					_ls_autoriza,		--21
					_listado,
					_seleccionado
	                with resume;


end foreach

--drop table temp_carta2016;
--drop table if exists temp_carta2016;

end procedure;