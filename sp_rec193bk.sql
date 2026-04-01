--Informacion para el calculo de IBNR, solicitado por Vicente Palumbo
--Armando Moreno
--09/04/2012
--execute procedure sp_rec193('001','001','2010-01','2010-03','002;')

--DROP procedure sp_rec193bk;
CREATE PROCEDURE "informix".sp_rec193bk(
a_compania  CHAR(3), 
a_agencia   CHAR(3), 
a_periodo1  CHAR(7), 
a_periodo2  CHAR(7), 
a_ramo      CHAR(255) DEFAULT "*"
) RETURNING CHAR(18), 
  		    CHAR(100), 
  		    CHAR(20),
  		    DATE,
  		    DECIMAL(16,2),
  		    DECIMAL(16,2),
  		    DECIMAL(16,2),
  		    DECIMAL(16,2),
  		    DECIMAL(16,2),
  		    DECIMAL(16,2);


DEFINE v_doc_reclamo     CHAR(18);
DEFINE _tipo             CHAR(1);
DEFINE v_cliente_nombre  CHAR(100);    
DEFINE v_doc_poliza      CHAR(20);     
DEFINE v_fecha_siniestro DATE;         
DEFINE v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE v_reserva_bruto   DECIMAL(16,2);
DEFINE v_reserva_neto    DECIMAL(16,2);
DEFINE v_incurrido_bruto DECIMAL(16,2);
DEFINE v_incurrido_neto  DECIMAL(16,2);
DEFINE v_ramo_nombre,v_agente_nombre     CHAR(50);     
DEFINE v_compania_nombre CHAR(50);     
DEFINE v_filtros         CHAR(255);

DEFINE _no_reclamo,v_codigo       CHAR(10);
DEFINE v_saber		     CHAR(3);
DEFINE _no_poliza        CHAR(10);     
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_agente       CHAR(5);
DEFINE _cod_cliente      CHAR(10);     
DEFINE _periodo          CHAR(7);
define _no_registro		 char(10);
define _sac_notrx        integer;
define _res_comprobante	 char(15);
define _parti_reas		 dec(16,2);
define _cnt              integer;
define _no_tranrec       char(10);
define _valor     		 dec(16,2);
define _transaccion      char(10);
define _incurrido_bruto  dec(16,2);
define _incurrido_neto	 dec(16,2);
DEFINE _n_contrato       varchar(50);
define _fecha_reclamo    date;
define _numrecla         char(18);
define _pagado_total  	 dec(16,2);
define _pag_jul			 dec(16,2);
define _pag_ago			 dec(16,2);
define _pag_sep			 dec(16,2);
define _pag_oct			 dec(16,2);
define _pag_nov			 dec(16,2);
define _pag_dic			 dec(16,2);

CREATE TEMP TABLE tmp_incurrido(
		no_reclamo           CHAR(10)  NOT NULL,
		pagado_total         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_bruto         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_neto          DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_total        DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_bruto        DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_neto         DEC(16,2) DEFAULT 0 NOT NULL,
		incurrido_abierto	 DEC(16,2) DEFAULT 0 NOT NULL,
		periodo				 CHAR(7)  NOT NULL,
		transaccion          CHAR(10)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_incurrido ON tmp_incurrido(no_reclamo);
CREATE INDEX xie02_tmp_incurrido ON tmp_incurrido(no_reclamo,periodo);

CREATE TEMP TABLE tmp_salida(
		no_reclamo           CHAR(10)  NOT NULL,
		pagado_jul           DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_ago           DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_sep           DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_oct           DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_nov           DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_dic           DEC(16,2) DEFAULT 0 NOT NULL,
		PRIMARY KEY (no_reclamo)
		) WITH NO LOG;



SET ISOLATION TO DIRTY READ;
-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania); 

let  v_filtros = "";
let _pag_jul   = 0;
let	_pag_ago   = 0;
let	_pag_sep   = 0;
let	_pag_oct   = 0;
let	_pag_nov   = 0;
let	_pag_dic   = 0;
let _pagado_total = 0;

FOREACH 
 SELECT no_reclamo		
   INTO	_no_reclamo
   FROM recrcmae
  where actualizado   = 1
	and numrecla[1,2] = '02'
	and periodo       >= a_periodo1
	and periodo       <= a_periodo2

	LET v_filtros = sp_rec193a(a_compania,a_agencia,a_periodo1,a_periodo2,'*','*',a_ramo,'*','*','*','*','*',_no_reclamo);

END FOREACH

FOREACH 

	select no_reclamo,
	       sum(pagado_total),
	       periodo
	  into _no_reclamo,
	       _pagado_total,
		   _periodo
      from tmp_incurrido
	 group by no_reclamo,periodo
	 order by no_reclamo,periodo

       BEGIN
       ON EXCEPTION IN(-239)

		if _periodo = '2011-08' then

			update tmp_salida
			   set pagado_ago = pagado_ago + _pagado_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2011-09' then

			update tmp_salida
			   set pagado_sep = pagado_sep + _pagado_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2011-10' then

			update tmp_salida
			   set pagado_oct = pagado_oct + _pagado_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2011-11' then

			update tmp_salida
			   set pagado_nov = pagado_nov + _pagado_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2011-12' then

			update tmp_salida
			   set pagado_dic = pagado_dic + _pagado_total
			 where no_reclamo = _no_reclamo;
		end if

       END EXCEPTION

		if a_periodo1 = "2011-07" then
			let _pag_jul = _pagado_total;
		end if

		if a_periodo1 = "2011-08" then
			let _pag_ago = _pagado_total;
		end if

		if a_periodo1 = "2011-09" then
			let _pag_sep = _pagado_total;
		end if

		if a_periodo1 = "2011-10" then
			let _pag_oct = _pagado_total;
		end if


		if a_periodo1 = "2011-11" then
			let _pag_nov = _pagado_total;
		end if

		if a_periodo1 = "2011-12" then
			let _pag_dic = _pagado_total;
		end if

		INSERT INTO tmp_salida(
		no_reclamo,
		pagado_jul,
		pagado_ago,
		pagado_sep,
		pagado_oct,
		pagado_nov,
		pagado_dic
		)
		VALUES(
		_no_reclamo,
		_pag_jul,
		_pag_ago,
		_pag_sep,
		_pag_oct,
		_pag_nov,
		_pag_dic
		);

	  END

END FOREACH

foreach

	 select no_reclamo,
			pagado_jul,
			pagado_ago,
			pagado_sep,
			pagado_oct,
			pagado_nov,
			pagado_dic
	   into	_no_reclamo,
	        _pag_jul,
			_pag_ago,
			_pag_sep,
			_pag_oct,
			_pag_nov,
			_pag_dic
	   from tmp_salida
	  order by no_reclamo

	SELECT cod_reclamante,
		   fecha_reclamo,
		   no_documento,
		   numrecla
	  INTO _cod_cliente,
	  	   _fecha_reclamo,
		   v_doc_poliza,
		   v_doc_reclamo
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	SELECT nombre
	  INTO v_cliente_nombre		
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;


 		RETURN v_doc_reclamo,
		 	   v_cliente_nombre, 	
		 	   v_doc_poliza,		
		 	   _fecha_reclamo,
			   _pag_jul,
			   _pag_ago,
			   _pag_sep,
			   _pag_oct,
			   _pag_nov,
			   _pag_dic
			   WITH RESUME;

END FOREACH

update periodo
   set activo = 0
  where periodo = a_periodo1;

DROP TABLE tmp_salida;
DROP TABLE tmp_incurrido;
END PROCEDURE                                                                                                                       
