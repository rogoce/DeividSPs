--Informacion para el calculo de IBNR, solicitado por Vicente Palumbo
--Armando Moreno
--09/04/2012
--execute procedure sp_rec194('001','001','2011-07','2011-07','018;')
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
  		    DECIMAL(16,2);


define v_doc_reclamo     char(18);
define _tipo             char(1);
define v_cliente_nombre  char(100);    
define v_doc_poliza      char(20);     
define v_fecha_siniestro DATE;         
define v_pagado_bruto    DECIMAL(16,2);
define v_pagado_neto     DECIMAL(16,2);
define v_reserva_bruto   DECIMAL(16,2);
define v_reserva_neto    DECIMAL(16,2);
define v_incurrido_bruto DECIMAL(16,2);
define v_incurrido_neto  DECIMAL(16,2);
define v_ramo_nombre,v_agente_nombre     char(50);     
define v_compania_nombre                 char(50);     
define v_filtros                         char(255);

define _no_reclamo,v_codigo              char(10);
define v_saber		     char(3);
define _no_poliza        char(10);     
define _cod_ramo         char(3);
define _cod_agente       char(5);
define _cod_cliente      char(10);     
define _periodo          char(7);
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
define _n_contrato       varchar(50);
define _fecha_reclamo    date;
define _fecha_siniestro  date;
define _numrecla         char(18);
define _pagado_total     dec(16,2);
define _reserva_total    dec(16,2);
define _incurrido_total  dec(16,2);
define _inc_tot_jul		 dec(16,2);
define _inc_tot_ago		 dec(16,2);
define _inc_tot_sep		 dec(16,2);
define _inc_tot_oct		 dec(16,2);
define _inc_tot_nov		 dec(16,2);
define _inc_tot_dic		 dec(16,2);
define _per_sin          char(7);

CREATE TEMP TABLE tmp_incurrido(
		no_reclamo            CHAR(10)  NOT NULL,
		pagado_total          DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_total         DEC(16,2) DEFAULT 0 NOT NULL,
		periodo				  CHAR(7)   NOT NULL
		) WITH NO LOG;

CREATE INDEX xie01_tmp_incurrido ON tmp_incurrido(no_reclamo);
CREATE INDEX xie02_tmp_incurrido ON tmp_incurrido(no_reclamo,periodo);

CREATE TEMP TABLE tmp_salida(
		no_reclamo            CHAR(10)  NOT NULL,
		inc_tot_jul           DEC(16,2) DEFAULT 0 NOT NULL,
		inc_tot_ago           DEC(16,2) DEFAULT 0 NOT NULL,
		inc_tot_sep           DEC(16,2) DEFAULT 0 NOT NULL,
		inc_tot_oct           DEC(16,2) DEFAULT 0 NOT NULL,
		inc_tot_nov           DEC(16,2) DEFAULT 0 NOT NULL,
		inc_tot_dic           DEC(16,2) DEFAULT 0 NOT NULL,
		PRIMARY KEY (no_reclamo)
		) WITH NO LOG;



SET ISOLATION TO DIRTY READ;
-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania); 

let  v_filtros       = "";
let _inc_tot_jul   	 = 0;
let	_inc_tot_ago   	 = 0;
let	_inc_tot_sep   	 = 0;
let	_inc_tot_oct   	 = 0;
let	_inc_tot_nov   	 = 0;
let	_inc_tot_dic   	 = 0;
let _incurrido_total = 0;

FOREACH 
 select no_reclamo,fecha_siniestro 
   into	_no_reclamo,_fecha_siniestro 
   from recrcmae
  where actualizado   = 1
	and numrecla[1,2] = '02'
	and periodo       = a_periodo1

      call sp_sis39(_fecha_siniestro) returning _per_sin;
		if _per_sin <> a_periodo1 then
		   continue foreach;
	   end if

	   let v_filtros = sp_rec194a(a_compania,a_agencia,a_periodo1,'2011-07','*','*',a_ramo,'*','*','*','*','*',_no_reclamo);

END FOREACH

FOREACH 
	select no_reclamo,
	       sum(pagado_total),
	       sum(reserva_total),
	       periodo
	  into _no_reclamo,
	       _pagado_total,
		   _reserva_total,
		   _periodo
      from tmp_incurrido
	 group by no_reclamo,periodo
	 order by no_reclamo,periodo

		if _pagado_total is null then
	   	   Let _pagado_total = 0;
	   end if

		if _reserva_total is null then
	   	   Let _reserva_total = 0;
	   end if

	   let _incurrido_total =  _pagado_total + _reserva_total; 

       BEGIN
       ON EXCEPTION IN(-239)

		if _periodo = '2011-08' then

			update tmp_salida
			   set inc_tot_ago = inc_tot_ago + _incurrido_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2011-09' then

			update tmp_salida
			   set inc_tot_sep = inc_tot_sep + _incurrido_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2011-10' then

			update tmp_salida
			   set inc_tot_oct = inc_tot_oct + _incurrido_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2011-11' then

			update tmp_salida
			   set inc_tot_nov = inc_tot_nov + _incurrido_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2011-12' then

			update tmp_salida
			   set inc_tot_dic = inc_tot_dic + _incurrido_total
			 where no_reclamo = _no_reclamo;
		end if

       END EXCEPTION

		if a_periodo1 = "2011-07" then
			let _inc_tot_jul = _incurrido_total;
		end if

		if a_periodo1 = "2011-08" then
			let _inc_tot_ago = _incurrido_total;
		end if

		if a_periodo1 = "2011-09" then
			let _inc_tot_sep = _incurrido_total;
		end if

		if a_periodo1 = "2011-10" then
			let _inc_tot_oct = _incurrido_total;
		end if


		if a_periodo1 = "2011-11" then
			let _inc_tot_nov = _incurrido_total;
		end if

		if a_periodo1 = "2011-12" then
			let _inc_tot_dic = _incurrido_total;
		end if

		INSERT INTO tmp_salida(
		no_reclamo,
		inc_tot_jul,
		inc_tot_ago,
		inc_tot_sep,
		inc_tot_oct,
		inc_tot_nov,
		inc_tot_dic
		)
		VALUES(
		_no_reclamo,
		_inc_tot_jul,
		_inc_tot_ago,
		_inc_tot_sep,
		_inc_tot_oct,
		_inc_tot_nov,
		_inc_tot_dic
		);

	  END

END FOREACH

foreach

	 select no_reclamo,
			inc_tot_jul,
			inc_tot_ago,
			inc_tot_sep,
			inc_tot_oct,
			inc_tot_nov,
			inc_tot_dic
	   into	_no_reclamo,
	        _inc_tot_jul,
			_inc_tot_ago,
			_inc_tot_sep,
			_inc_tot_oct,
			_inc_tot_nov,
			_inc_tot_dic
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


 		RETURN v_doc_reclamo,
		 	   v_cliente_nombre, 	
		 	   v_doc_poliza,		
		 	   _fecha_siniestro,
			   _inc_tot_jul,
			   _inc_tot_ago,
			   _inc_tot_sep,
			   _inc_tot_oct,
			   _inc_tot_nov,
			   _inc_tot_dic
			   WITH RESUME;

END FOREACH

update periodo
   set activo = 0
  where periodo = a_periodo1;

DROP TABLE tmp_salida;
DROP TABLE tmp_incurrido;
END PROCEDURE                                                                                                                       
