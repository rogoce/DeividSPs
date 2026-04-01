--Informacion para el calculo de IBNR, solicitado por Vicente Palumbo
--Armando Moreno
--09/04/2012
--execute procedure sp_rec194('001','001','2011-07','2011-07','018;')

--Tabla periodo, campo activo poner todos en 1, luego que se tira enero, poner 0 a enero y asi sucecivamente.


DROP procedure sp_rec194;
CREATE PROCEDURE "informix".sp_rec194(
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
  		    DECIMAL(16,2),
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
define _fecha_siniestro  date;
define _numrecla         char(18);
define _pagado_total  	 dec(16,2);
define _pag_ene			 dec(16,2);
define _pag_feb			 dec(16,2);
define _pag_mar			 dec(16,2);
define _pag_abr			 dec(16,2);
define _pag_may			 dec(16,2);
define _pag_jun			 dec(16,2);
define _pag_jul			 dec(16,2);
define _pag_ago			 dec(16,2);
define _pag_sep			 dec(16,2);
define _pag_oct			 dec(16,2);
define _pag_nov			 dec(16,2);
define _pag_dic			 dec(16,2);
define _reserva_total    dec(16,2);
define _incurrido_total  dec(16,2);


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
		periodo_pago		 CHAR(7)  NOT NULL,
		fecha_entrada        DATE
		) WITH NO LOG;

CREATE INDEX xie01_tmp_incurrido ON tmp_incurrido(no_reclamo);
CREATE INDEX xie02_tmp_incurrido ON tmp_incurrido(no_reclamo,periodo_pago);

CREATE TEMP TABLE tmp_salida(
		no_reclamo           CHAR(10)  NOT NULL,
		pagado_ene           DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_feb           DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_mar           DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_abr           DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_may           DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_jun           DEC(16,2) DEFAULT 0 NOT NULL,
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
let _pagado_total = 0;
let _reserva_total = 0;
let _incurrido_total = 0;
let _no_reclamo = "";

call sp_rec194a(a_compania,a_agencia,a_periodo1) returning v_filtros;

--set debug file to "sp_rec194.trc";
--trace on;

FOREACH 
	select no_reclamo,
	       sum(pagado_total),
	       sum(reserva_total),
	       periodo_pago
	  into _no_reclamo,
	       _pagado_total,
		   _reserva_total,
		   _periodo
      from tmp_incurrido
	 group by no_reclamo,periodo_pago
	 order by no_reclamo,periodo_pago

		let a_periodo1 = _periodo;

		if _pagado_total is null then
	   	   Let _pagado_total = 0;
	   end if

		if _reserva_total is null then
	   	   Let _reserva_total = 0;
	   end if

	   let _incurrido_total =  _pagado_total + _reserva_total; 

       BEGIN
       ON EXCEPTION IN(-239)


		if _periodo = '2012-02' then

			update tmp_salida
			   set pagado_feb = pagado_feb + _incurrido_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2012-03' then

			update tmp_salida
			   set pagado_mar = pagado_mar + _incurrido_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2012-04' then

			update tmp_salida
			   set pagado_abr = pagado_abr + _incurrido_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2012-05' then

			update tmp_salida
			   set pagado_may = pagado_may + _incurrido_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2012-06' then

			update tmp_salida
			   set pagado_jun = pagado_jun + _incurrido_total
			 where no_reclamo = _no_reclamo;

		end if

		if _periodo = '2012-07' then

			update tmp_salida
			   set pagado_jul = pagado_jul + _incurrido_total
			 where no_reclamo = _no_reclamo;

		end if

		if _periodo = '2012-08' then

			update tmp_salida
			   set pagado_ago = pagado_ago + _incurrido_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2012-09' then

			update tmp_salida
			   set pagado_sep = pagado_sep + _incurrido_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2012-10' then

			update tmp_salida
			   set pagado_oct = pagado_oct + _incurrido_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2012-11' then

			update tmp_salida
			   set pagado_nov = pagado_nov + _incurrido_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2012-12' then

			update tmp_salida
			   set pagado_dic = pagado_dic + _incurrido_total
			 where no_reclamo = _no_reclamo;

		end if

       END EXCEPTION

	  let _pag_ene   = 0;
	  let _pag_feb   = 0;
	  let _pag_mar   = 0;
	  let _pag_abr   = 0;
	  let _pag_may   = 0;
	  let _pag_jun   = 0;
	  let _pag_jul   = 0;
	  let _pag_ago   = 0;
	  let _pag_sep   = 0;
	  let _pag_oct   = 0;
	  let _pag_nov   = 0;
	  let _pag_dic   = 0;

		if a_periodo1 = "2012-01" then
			let _pag_ene = _incurrido_total;
		end if

		if a_periodo1 = "2012-02" then
			let _pag_feb = _incurrido_total;
		end if

		if a_periodo1 = "2012-03" then
			let _pag_mar = _incurrido_total;
		end if

		if a_periodo1 = "2012-04" then
			let _pag_abr = _incurrido_total;
		end if


		if a_periodo1 = "2012-05" then
			let _pag_may = _incurrido_total;
		end if

		if a_periodo1 = "2012-06" then
			let _pag_jun = _incurrido_total;
		end if

		if a_periodo1 = "2012-07" then
			let _pag_jul = _incurrido_total;
		end if

		if a_periodo1 = "2012-08" then
			let _pag_ago = _incurrido_total;
		end if

		if a_periodo1 = "2012-09" then
			let _pag_sep = _incurrido_total;
		end if

		if a_periodo1 = "2012-10" then
			let _pag_oct = _incurrido_total;
		end if

		if a_periodo1 = "2012-11" then
			let _pag_nov = _incurrido_total;
		end if

		if a_periodo1 = "2012-12" then
			let _pag_dic = _incurrido_total;
		end if

		INSERT INTO tmp_salida(
		no_reclamo,
		pagado_ene,
		pagado_feb,
		pagado_mar,
		pagado_abr,
		pagado_may,
		pagado_jun,
		pagado_jul,
		pagado_ago,
		pagado_sep,
		pagado_oct,
		pagado_nov,
		pagado_dic
		)
		VALUES(
		_no_reclamo,
		_pag_ene,
		_pag_feb,
		_pag_mar,
		_pag_abr,
		_pag_may,
		_pag_jun,
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
			pagado_ene,
			pagado_ene + pagado_feb,
			pagado_ene + pagado_feb + pagado_mar,
			pagado_ene + pagado_feb + pagado_mar + pagado_abr,
			pagado_ene + pagado_feb + pagado_mar + pagado_abr + pagado_may,
			pagado_ene + pagado_feb + pagado_mar + pagado_abr + pagado_may + pagado_jun,
			pagado_ene + pagado_feb + pagado_mar + pagado_abr + pagado_may + pagado_jun + pagado_jul,
			pagado_ene + pagado_feb + pagado_mar + pagado_abr + pagado_may + pagado_jun + pagado_jul + pagado_ago,
			pagado_ene + pagado_feb + pagado_mar + pagado_abr + pagado_may + pagado_jun + pagado_jul + pagado_ago + pagado_sep,
			pagado_ene + pagado_feb + pagado_mar + pagado_abr + pagado_may + pagado_jun + pagado_jul + pagado_ago + pagado_sep + pagado_oct,
			pagado_ene + pagado_feb + pagado_mar + pagado_abr + pagado_may + pagado_jun + pagado_jul + pagado_ago + pagado_sep + pagado_oct + pagado_nov,
			pagado_ene + pagado_feb + pagado_mar + pagado_abr + pagado_may + pagado_jun + pagado_jul + pagado_ago + pagado_sep + pagado_oct + pagado_nov + pagado_dic
	   into	_no_reclamo,
	        _pag_ene,
			_pag_feb,
			_pag_mar,
			_pag_abr,
			_pag_may,
			_pag_jun,
	        _pag_jul,
			_pag_ago,
			_pag_sep,
			_pag_oct,
			_pag_nov,
			_pag_dic
	   from tmp_salida
	  order by no_reclamo

	SELECT cod_reclamante,
		   fecha_siniestro,
		   no_documento,
		   numrecla
	  INTO _cod_cliente,
	  	   _fecha_siniestro,
		   v_doc_poliza,
		   v_doc_reclamo
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	SELECT nombre
	  INTO v_cliente_nombre		
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;

    select min(fecha_entrada) into _fecha_reclamo from tmp_incurrido where no_reclamo = _no_reclamo;

    
 		RETURN v_doc_reclamo,
		 	   v_cliente_nombre, 	
		 	   v_doc_poliza,		
		 	   _fecha_reclamo,
	           _pag_ene,
			   _pag_feb,
			   _pag_mar,
			   _pag_abr,
			   _pag_may,
			   _pag_jun,
	           _pag_jul,
			   _pag_ago,
			   _pag_sep,
			   _pag_oct,
			   _pag_nov,
			   _pag_dic
			   WITH RESUME;

END FOREACH

DROP TABLE tmp_salida;
DROP TABLE tmp_incurrido;

END PROCEDURE                                                                                                                       
 