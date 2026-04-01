-- Procedimiento que Genera la Morosidad Total por Ramo
-- 
-- Creado    : 09/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 09/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 28/01/2002 Adicion del campo Grupo - Autor: Amado Perez
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob122;

CREATE PROCEDURE "informix".sp_cob122(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_fecha    DATE
) returning char(50),
	        integer,
	        dec(16,2),
	        dec(16,2),
	        dec(16,2),
	        dec(16,2),
	        dec(16,2),
	        dec(16,2),
	        dec(16,2),
	        dec(16,2),
		    char(50),
		    char(255),
		    char(3);


DEFINE _no_poliza       CHAR(10);
DEFINE _cod_ramo        CHAR(3); 
DEFINE _prima_orig      DEC(16,2);
DEFINE _saldo           DEC(16,2);
DEFINE _por_vencer      DEC(16,2);
DEFINE _exigible        DEC(16,2);
DEFINE _corriente       DEC(16,2);
DEFINE _monto_30        DEC(16,2);
DEFINE _monto_60        DEC(16,2);
DEFINE _monto_90        DEC(16,2);

DEFINE _cod_tipoprod    CHAR(3);
DEFINE _no_documento    CHAR(20);

DEFINE _mes_contable    CHAR(2);
DEFINE _ano_contable    CHAR(4);
DEFINE _periodo         CHAR(7);
DEFINE _incobrable      INT;

define _nombre_ramo		char(50);
define _nombre_compania	char(50);

define _porc_coas		dec(16,4);

SET ISOLATION TO DIRTY READ;
 
let _nombre_compania = sp_sis01(a_compania);

-- Tabla Temporal 

--DROP TABLE tmp_moros;

CREATE TEMP TABLE tmp_apadea(
		cod_tipoprod	char(3),
		cod_ramo        CHAR(3),
		prima_orig      DEC(16,2)	DEFAULT 0 NOT NULL,
		saldo           DEC(16,2)	DEFAULT 0 NOT NULL,
		por_vencer      DEC(16,2)	DEFAULT 0 NOT NULL,
		exigible        DEC(16,2)	DEFAULT 0 NOT NULL,
		corriente       DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_30        DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_60        DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_90        DEC(16,2)	DEFAULT 0 NOT NULL
		) WITH NO LOG;


--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob02.trc";

-- Periodo de Seleccion
-- Se Filtran los Registros por Fecha y Periodo Contable

LET _ano_contable = YEAR(a_fecha);

IF MONTH(a_fecha) < 10 THEN
	LET _mes_contable = '0' || MONTH(a_fecha);
ELSE
	LET _mes_contable = MONTH(a_fecha);
END IF

LET _periodo = _ano_contable || '-' || _mes_contable;

BEGIN 

-- Seleccion de la Polizas

FOREACH 
 SELECT no_documento
   INTO	_no_documento
   FROM emipomae 
  WHERE cod_compania  = a_compania		   -- Seleccion por Compania
    AND actualizado   = 1			   	   -- Poliza este actualizada
	and cod_tipoprod  <> "004"
  GROUP BY no_documento

	let _no_poliza = sp_sis21(_no_documento);

	SELECT cod_ramo,
		   prima_bruta,
		   cod_tipoprod
	  INTO _cod_ramo,
		   _prima_orig,
		   _cod_tipoprod
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	if _cod_tipoprod = "004" then
   		CONTINUE FOREACH;
    END IF

	-- Procedimiento que genera la morosidad para una poliza

	CALL sp_cob33(
		 a_compania,
		 a_agencia,
		 _no_documento,
		 _periodo,
		 a_fecha
		 ) RETURNING _por_vencer,       
    				 _exigible,         
    				 _corriente,        
    				 _monto_30,         
    				 _monto_60,         
    				 _monto_90,
					 _saldo;          

   IF _saldo = 0 THEN
   		CONTINUE FOREACH;
   END IF

	if _cod_tipoprod = "001" then

		select porc_partic_coas
		  into _porc_coas
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = "036";

		let _prima_orig = _prima_orig * _porc_coas / 100;     
		let _por_vencer = _por_vencer * _porc_coas / 100;     
		let _exigible   = _exigible   * _porc_coas / 100;    
		let _corriente  = _corriente  * _porc_coas / 100;    
		let _monto_30   = _monto_30   * _porc_coas / 100;    
		let _monto_60   = _monto_60   * _porc_coas / 100;    
		let _monto_90	= _monto_90	  * _porc_coas / 100;
		let _saldo      = _saldo      * _porc_coas / 100;  

		let _cod_tipoprod = "005";

	end if

	-- Actualizacion de la Tabla Temporal

	INSERT INTO tmp_apadea(
	cod_tipoprod,
	cod_ramo,      
	prima_orig,    
	saldo,          
	por_vencer,     
	exigible,       
	corriente,     
	monto_30,       
	monto_60,       
	monto_90
	)
	VALUES(
	_cod_tipoprod,
	_cod_ramo,
	_prima_orig,    
	_saldo,          
	_por_vencer,     
	_exigible,       
	_corriente,     
	_monto_30,       
	_monto_60,       
	_monto_90
	);

END FOREACH

call sp_par78a(a_compania, a_agencia, a_fecha);

foreach
 select no_poliza,
		cod_ramo,
	    prima_orig,    
	    saldo,          
	    por_vencer,     
	    exigible,       
	    corriente,     
	    monto_30,       
	    monto_60,       
	    monto_90
   into	_no_poliza,
		_cod_ramo,
	    _prima_orig,    
	    _saldo,          
	    _por_vencer,     
	    _exigible,       
	    _corriente,     
	    _monto_30,       
	    _monto_60,       
	    _monto_90
   from	tmp_moros

	SELECT cod_tipoprod
	  INTO _cod_tipoprod
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	if _cod_tipoprod = "001" then

		select porc_partic_coas
		  into _porc_coas
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = "036";

		let _prima_orig = _prima_orig * _porc_coas / 100;     
		let _por_vencer = _por_vencer * _porc_coas / 100;     
		let _exigible   = _exigible   * _porc_coas / 100;    
		let _corriente  = _corriente  * _porc_coas / 100;    
		let _monto_30   = _monto_30   * _porc_coas / 100;    
		let _monto_60   = _monto_60   * _porc_coas / 100;    
		let _monto_90	= _monto_90	  * _porc_coas / 100;
		let _saldo      = _saldo      * _porc_coas / 100;  

	end if

	let _cod_tipoprod = "009";

	-- Actualizacion de la Tabla Temporal

	INSERT INTO tmp_apadea(
	cod_tipoprod,
	cod_ramo,      
	prima_orig,    
	saldo,          
	por_vencer,     
	exigible,       
	corriente,     
	monto_30,       
	monto_60,       
	monto_90
	)
	VALUES(
	_cod_tipoprod,
	_cod_ramo,
	_prima_orig,    
	_saldo,          
	_por_vencer,     
	_exigible,       
	_corriente,     
	_monto_30,       
	_monto_60,       
	_monto_90
	);

end foreach

foreach
 select cod_tipoprod,
 		cod_ramo,
        count(*),
	    sum(prima_orig),    
	    sum(saldo),          
	    sum(por_vencer),     
	    sum(exigible),       
	    sum(corriente),     
	    sum(monto_30),       
	    sum(monto_60),       
	    sum(monto_90)
   into	_cod_tipoprod,
   		_cod_ramo,
        _incobrable,
	    _prima_orig,    
	    _saldo,          
	    _por_vencer,     
	    _exigible,       
	    _corriente,     
	    _monto_30,       
	    _monto_60,       
	    _monto_90
   from	tmp_apadea
  group by 1, 2
  order by 1, 2

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	return _nombre_ramo,
	       _incobrable,
	       _prima_orig,    
	       _saldo,          
	       _por_vencer,     
	       _exigible,       
	       _corriente,     
	       _monto_30,       
	       _monto_60,       
	       _monto_90,
		   _nombre_compania,
		   "",
		   _cod_tipoprod
		   with resume;

end foreach

drop table tmp_apadea;
drop table tmp_moros;

END

END PROCEDURE;
