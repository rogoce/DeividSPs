-- Reporte para movimientos de una remesa 660575.
--Armando Moreno 18/06/2013


DROP PROCEDURE sp_leyri11;		

CREATE PROCEDURE "informix".sp_leyri11(
a_compania   CHAR(3),
a_agencia    CHAR(3),
a_no_remesa  CHAR(10)
) 
RETURNING CHAR(20),CHAR(10),CHAR(10),VARCHAR(100),CHAR(20),CHAR(10),DEC(16,2),DEC(16,2),CHAR(7),CHAR(5),VARCHAR(50),CHAR(5),VARCHAR(50),DEC(16,2);

DEFINE _no_poliza         CHAR(10); 
DEFINE _no_poliza_ult     CHAR(10); 
DEFINE _nombre_cliente    CHAR(100);
DEFINE _doc_poliza        CHAR(20); 
DEFINE _no_documento      CHAR(20);
DEFINE _estatus           SMALLINT;
DEFINE _estatus_char      char(10);
DEFINE _fecha_ult_pago    DATE;
DEFINE _prima_neta		  dec(16,2);
DEFINE _saldo             DEC(16,2);
DEFINE _monto             DEC(16,2);
DEFINE _monto_imp         DEC(16,2);
DEFINE _cod_cliente       CHAR(10);
DEFINE _cod_grupo         CHAR(5); 
DEFINE _cod_grupo2        CHAR(5); 
DEFINE _nombre_grupo      VARCHAR(50);
DEFINE _nombre_grupo2     VARCHAR(50);
DEFINE _tipo              CHAR(7);
DEFINE _saldo2            DEC(16,2);
DEFINE v_por_vencer	  	  DEC(16,2);
DEFINE v_exigible  	  	  DEC(16,2);
DEFINE v_corriente 	  	  DEC(16,2);
DEFINE v_monto_30  	  	  DEC(16,2);
DEFINE v_monto_60  	  	  DEC(16,2);
DEFINE v_monto_90		  DEC(16,2);



SET ISOLATION TO DIRTY READ;

-- Tabla Temporal 

--DROP TABLE tmp_moros;

CREATE TEMP TABLE tmp_moros(
		no_documento    CHAR(20)	NOT NULL,
		cod_contratante char(10)    NOT NULL,
		no_poliza       CHAR(10)	NOT NULL,
		nombre_cliente  CHAR(100)	NOT NULL,
		doc_poliza      CHAR(20),
		estatus         smallint    NOT NULL,
		fecha_ult_mov   DATE,
		prima_neta      DEC(16,2)	DEFAULT 0 NOT NULL,
		saldo           DEC(16,2)	DEFAULT 0 NOT NULL,
		saldo_imp       DEC(16,2)   DEFAULT 0 NOT NULL,
		tipo            char(7),
		cod_grupo       char(5),
		nombre_grupo    varchar(50),
		cod_grupo2      char(5),
		nombre_grupo2   varchar(50),
		saldo2          DEC(16,2)   DEFAULT 0 NOT NULL
		) WITH NO LOG;

CREATE INDEX xie01_tmp_moros ON tmp_moros(doc_poliza);
CREATE INDEX xie02_tmp_moros ON tmp_moros(tipo);

-- Seleccion de la Polizas

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03.trc";   
--TRACE ON;                                                                  

--Cliente

let v_por_vencer = 0;
let v_exigible   = 0;
let v_corriente  = 0;
let	v_monto_30   = 0;
let	v_monto_60   = 0;
let	v_monto_90	 = 0;
let	_saldo		 = 0;
let	_saldo2		 = 0;

FOREACH

 SELECT no_poliza, doc_remesa
   INTO _no_poliza,_doc_poliza
   FROM cobredet
  WHERE no_remesa    = a_no_remesa
    AND actualizado  = 1
	AND renglon      <> 1

 SELECT	cod_contratante
   INTO	_cod_cliente
   FROM	emipomae
  WHERE no_poliza = _no_poliza;

let _nombre_grupo2 = "";

select cod_grupo
  into _cod_grupo2
  from emipomae
 where no_poliza = _no_poliza;


SELECT nombre
  INTO _nombre_grupo2
  FROM cligrupo
 WHERE cod_grupo = _cod_grupo2;


	foreach

		select no_documento
		  into _no_documento
		  from emipomae
		 where actualizado     = 1
		   and cod_contratante = _cod_cliente
		   and no_documento    <> _doc_poliza
	     group by no_documento
		 order by no_documento

        let _no_poliza_ult = sp_sis21(_no_documento);
		let _saldo2        = sp_cob174(_no_documento);
		call sp_cob33('001','001', _no_documento, '2012-12', '31/12/2012') --saldo al 31/12/2012
		     returning v_por_vencer,    
		               v_exigible,      
		               v_corriente,    
		               v_monto_30,      
		               v_monto_60,      
		               v_monto_90,
		               _saldo;

        select estatus_poliza,
		       prima_neta,
			   cod_grupo
		  into _estatus,
		       _prima_neta,
			   _cod_grupo
		  from emipomae
		 where no_poliza = _no_poliza_ult;

	   	SELECT nombre
		  INTO _nombre_cliente
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

	   	SELECT nombre
		  INTO _nombre_grupo
		  FROM cligrupo
		 WHERE cod_grupo = _cod_grupo;

        insert into tmp_moros(
		no_documento,
		cod_contratante,
		no_poliza,
		nombre_cliente,
		doc_poliza,   
		estatus,      
--		fecha_ult_mov,
		prima_neta,   
		saldo,
		tipo,
		cod_grupo,
		nombre_grupo,
		cod_grupo2,
		nombre_grupo2,
		saldo2)
		values(
		_no_documento,
		_cod_cliente,
		_no_poliza_ult,
		_nombre_cliente,    
		_doc_poliza,
		_estatus,
--		'',
		_prima_neta,
		_saldo,
		'CLIENTE',
		_cod_grupo,
		_nombre_grupo,
		_cod_grupo2,
		_nombre_grupo2,
		_saldo2);

	end foreach

END FOREACH

{--Grupo

FOREACH

 SELECT c.no_poliza, c.doc_remesa, e.cod_grupo
   INTO _no_poliza,_doc_poliza,_cod_grupo
   FROM cobredet c, emipomae e
  WHERE c.no_poliza = e.no_poliza
    AND c.no_remesa    = a_no_remesa
    AND c.actualizado  = 1
	AND c.renglon      <> 1
	AND e.cod_grupo    <> '00001'  --SIN GRUPO NO VA

 select count(*)
   into _cnt
   from tmp_moros
  where cod_grupo = _cod_grupo
    and tipo      = 'GRUPO';

if _cnt = 0 then

	foreach

		select no_documento
		  into _no_documento
		  from emipomae
		 where actualizado     = 1
		   and cod_grupo       = _cod_grupo
		   and no_documento    not in (select doc_remesa from cobredet where no_remesa = a_no_remesa)
	     group by no_documento
		 order by no_documento

        let _no_poliza_ult = sp_sis21(_no_documento);
		let _saldo         = sp_cob174(_no_documento);

        select estatus_poliza,
		       prima_neta,
			   cod_contratante
		  into _estatus,
		       _prima_neta,
			   _cod_cliente
		  from emipomae
		 where no_poliza = _no_poliza_ult;

	   	SELECT nombre
		  INTO _nombre_cliente
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;


	   	SELECT nombre
		  INTO _nombre_grupo
		  FROM cligrupo
		 WHERE cod_grupo = _cod_grupo;

        insert into tmp_moros(
		no_documento,
		cod_contratante,
		no_poliza,
		nombre_cliente,
		doc_poliza,   
		estatus,      
		prima_neta,   
		saldo,
		tipo,
		cod_grupo,
		nombre_grupo)
		values(
		_no_documento,
		_cod_cliente,
		_no_poliza_ult,
		_nombre_cliente,    
		_doc_poliza,
		_estatus,
		_prima_neta,
		_saldo,
		'GRUPO',
		_cod_grupo,
		_nombre_grupo);

	end foreach
end if
END FOREACH	}

foreach

	select no_documento,
		   cod_contratante,
		   no_poliza,
		   nombre_cliente,
		   doc_poliza,   
		   estatus,      
		   prima_neta,   
		   saldo,
		   tipo,
		   cod_grupo,
		   nombre_grupo,
		   cod_grupo2,
		   nombre_grupo2,
		   saldo2
	  into _no_documento,
		   _cod_cliente,
		   _no_poliza_ult,
		   _nombre_cliente,
		   _doc_poliza,
		   _estatus,
		   _prima_neta,
		   _saldo,
		   _tipo,
		   _cod_grupo,
		   _nombre_grupo,
		   _cod_grupo2,
		   _nombre_grupo2,
		   _saldo2
	  from tmp_moros
	 order by tipo,doc_poliza

    if _estatus = 1 then
	   let _estatus_char = 'VIGENTE';
	elif _estatus = 2 then
	   let _estatus_char = 'CANCELADA';
	elif _estatus = 3 then
	   let _estatus_char = 'VENCIDA';
	end if

	return _no_documento,_cod_cliente,_no_poliza_ult,_nombre_cliente,_doc_poliza,_estatus_char,_prima_neta,_saldo,_tipo,_cod_grupo,_nombre_grupo,_cod_grupo2,_nombre_grupo2,_saldo2 with resume;

end foreach

drop table tmp_moros;

END PROCEDURE;
