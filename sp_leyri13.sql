-- Reporte para movimientos de una remesa 660575.
--Armando Moreno 18/06/2013


DROP PROCEDURE sp_leyri13;		

CREATE PROCEDURE "informix".sp_leyri13(
a_compania   CHAR(3),
a_agencia    CHAR(3),
a_no_remesa  CHAR(10)
) 
RETURNING CHAR(20),CHAR(10),CHAR(10),VARCHAR(100),CHAR(20),DATE,CHAR(10),DEC(16,2),DEC(16,2),CHAR(7),CHAR(5),VARCHAR(50),char(5),varchar(50),decimal(5,2);

DEFINE _no_poliza         CHAR(10); 
DEFINE _no_poliza_ult     CHAR(10); 
DEFINE _nombre_cliente    CHAR(100);
DEFINE _doc_poliza        CHAR(20); 
DEFINE _no_documento      CHAR(20);
DEFINE _estatus           SMALLINT;
DEFINE _estatus_char      char(10);
DEFINE _fecha_ult_mov     DATE;
DEFINE _prima_neta		  dec(16,2);
DEFINE _saldo             DEC(16,2);
DEFINE _monto             DEC(16,2);
DEFINE _monto_imp         DEC(16,2);
DEFINE _cod_cliente       CHAR(10);
DEFINE _cod_grupo         CHAR(5); 
DEFINE _nombre_grupo      VARCHAR(50);
DEFINE _tipo              CHAR(7);
define _porc_comis_agt    decimal(5,2);
define _cod_agente        char(5);
define _n_agente          varchar(50);

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
		cod_agente      char(5),
		porc_comis_agt  decimal(5,2)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_moros ON tmp_moros(doc_poliza);
CREATE INDEX xie02_tmp_moros ON tmp_moros(tipo);

-- Seleccion de la Polizas

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03.trc";   
--TRACE ON;                                                                  

--Cliente

FOREACH

 SELECT no_poliza, doc_remesa
   INTO _no_poliza_ult,_no_documento
   FROM cobredet
  WHERE no_remesa    = a_no_remesa
    AND actualizado  = 1
	AND renglon      <> 1


        --let _no_poliza_ult = sp_sis21(_no_documento);
		let _saldo         = sp_cob174(_no_documento);
		let _fecha_ult_mov = sp_leyri12('001','001',_no_documento);

        select estatus_poliza,
		       prima_neta,
			   cod_grupo,
			   cod_contratante
		  into _estatus,
		       _prima_neta,
			   _cod_grupo,
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

		foreach
			select cod_agente,porc_comis_agt
			  into _cod_agente,_porc_comis_agt
			  from emipoagt
			 where no_poliza = _no_poliza_ult


	        insert into tmp_moros(
			no_documento,
			cod_contratante,
			no_poliza,
			nombre_cliente,
			doc_poliza,   
			estatus,      
			fecha_ult_mov,
			prima_neta,   
			saldo,
			tipo,
			cod_grupo,
			nombre_grupo,
			cod_agente,
			porc_comis_agt)
			values(
			_no_documento,
			_cod_cliente,
			_no_poliza_ult,
			_nombre_cliente,    
			_no_documento,
			_estatus,
			_fecha_ult_mov,
			_prima_neta,
			_saldo,
			'CLIENTE',
			_cod_grupo,
			_nombre_grupo,
			_cod_agente,
			_porc_comis_agt);

       end foreach
END FOREACH


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
		   fecha_ult_mov,
		   cod_agente,
		   porc_comis_agt
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
		   _fecha_ult_mov,
		   _cod_agente,
		   _porc_comis_agt
	  from tmp_moros
	 order by tipo,doc_poliza

    if _estatus = 1 then
	   let _estatus_char = 'VIGENTE';
	elif _estatus = 2 then
	   let _estatus_char = 'CANCELADA';
	elif _estatus = 3 then
	   let _estatus_char = 'VENCIDA';
	end if

	select nombre into _n_agente from agtagent where cod_agente = _cod_agente;

	return _no_documento,_cod_cliente,_no_poliza_ult,_nombre_cliente,_doc_poliza,_fecha_ult_mov,_estatus_char,_prima_neta,_saldo,_tipo,_cod_grupo,_nombre_grupo,_cod_agente,_n_agente,_porc_comis_agt with resume;

end foreach

drop table tmp_moros;

END PROCEDURE;
