-- Procedimiento que Crea los Registros para los Auditores (Cobros)
-- 
-- Creado     : 15/09/2004 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud52;

create procedure "informix".sp_aud52() 
       returning char(10), 
                 char(20), 
                 char(20),
				 varchar(50),
				 varchar(50),
				 varchar(50),
				 varchar(50),
                 varchar(100),
                 varchar(100),
                 date, 
                 date,
                 char(10),
                 varchar(50), 
                 varchar(100),
                 date,
				 dec(16,2),
				 datetime year to fraction(5),
				 varchar(255),
				 datetime year to fraction(5),
				 varchar(255),
				 datetime year to fraction(5),
				 varchar(255),
				 varchar(100),
                 varchar(50),
                 varchar(50), 
                 char(20);
              --   dec(16,2);   

define _no_tramite		char(10);
define _numrecla		char(20);
define _cod_asegurado	char(10);
define _cod_conductor 	char(10);
define _cod_abogado 	char(10);
define _fecha_siniestro	date;
define _fecha_reclamo	date;
define _cod_evento   	char(3);
define _cod_ajustador	char(3);
define _user_added  	char(8);
define _estatus_reclamo char(1);
define _no_poliza       char(10);
define _no_reclamo      char(10);
define _asegurado       varchar(100);
define _conductor       varchar(100);
define _abogado   		varchar(100);
define _evento          varchar(50);
define _cod_ramo        char(3);
define _ramo            varchar(50);
define _incurrido_bruto dec(16,2);
define _ajustador       varchar(50);
define _estatus     	char(15);

define _no_documento    char(20);
define _no_unidad       char(5);
define _ls_ded_col		varchar(50);
define _ls_ded_comp		varchar(50);
define _ls_ded_dan		varchar(50);
define _ls_ded_rem		varchar(50);
define _porc_partic_coas	dec(7,4);  -- % coaseguro

define _no_tranrec		  char(10);
define _monto_tran		  dec(16,2);
define _variacion		  dec(16,2);
define _cod_tipotran	  char(3);
define _tipo_transaccion  smallint;

define _sumar_incurrido	  dec(16,2);

define _desc_nota		  varchar(255);
define _desc_nota1		  varchar(255);
define _desc_nota2		  varchar(255);
define _desc_nota3		  varchar(255);

define _fecha_nota		  datetime year to fraction(5);
define _fecha_nota1		  datetime year to fraction(5);
define _fecha_nota2		  datetime year to fraction(5);
define _fecha_nota3		  datetime year to fraction(5);

define _transaccion		  char(10);
define _cod_tipopago	  char(3);
define _cod_cliente		  char(10);
define _fecha			  date;
define _monto			  dec(16,2);
						  
define _renglon			  smallint;

define _audiencia         char(20);
define _tipopago          varchar(50);
define _pagado      	  varchar(50);

define _estatus_audiencia  smallint;
DEFINE _cod_coasegur        CHAR(3);      


set isolation to dirty read;

LET _cod_coasegur     = sp_sis02('001', '001');

foreach
	select no_tramite, 
	       numrecla, 
	       no_documento,  
	       cod_asegurado, 
	       cod_conductor, 
	       fecha_siniestro, 
	       fecha_reclamo, 
	       cod_abogado, 
	       estatus_audiencia, 
	       cod_evento, 
	       ajust_interno, 
	       user_added, 
	       no_poliza, 
	       no_reclamo,
		   no_unidad
	  into _no_tramite, 
	       _numrecla, 
	       _no_documento, 
	       _cod_asegurado, 
	       _cod_conductor, 
	       _fecha_siniestro, 
	       _fecha_reclamo, 
	       _cod_abogado, 
	       _estatus_audiencia, 
	       _cod_evento, 
	       _cod_ajustador, 
	       _user_added, 
	       _no_poliza, 
	       _no_reclamo,
		   _no_unidad
	  from recrcmae
	 where estatus_reclamo = 'A'
	   and actualizado = 1

	select cod_ramo into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

    if _cod_ramo not in ('002','020') then
		continue foreach;
	end if

    select nombre into _asegurado
	  from cliclien 
	 where cod_cliente = _cod_asegurado;

    select nombre into _conductor
	  from cliclien 
	 where cod_cliente = _cod_conductor;

    select nombre into _abogado
	  from cliclien 
	 where cod_cliente = _cod_abogado;

    select nombre into _evento
	  from recevent
	 where cod_evento = _cod_evento;

    select nombre into _ajustador
	  from recajust
	 where cod_ajustador = _cod_ajustador;

	select nombre into _ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

    let _ls_ded_col = null;
    let _ls_ded_comp = null;
    let _ls_ded_dan = null;
    let _ls_ded_rem = null;

	SELECT deducible
	  INTO _ls_ded_col
	  FROM emipocob
	 WHERE no_poliza     = _no_poliza
	   AND no_unidad     = _no_unidad
	   AND cod_cobertura IN ("00119","00121"); --colision

	SELECT deducible
	  INTO _ls_ded_comp
	  FROM emipocob
	 WHERE no_poliza     = _no_poliza
	   AND no_unidad     = _no_unidad
       AND cod_cobertura IN ("00118","00900","00606"); --comprensivo

	SELECT deducible
	  INTO _ls_ded_dan
	  FROM emipocob
	 WHERE no_poliza     = _no_poliza
	   AND no_unidad     = _no_unidad
       AND cod_cobertura IN("00113","01022"); --Danos P.A.
 
	SELECT deducible
	  INTO _ls_ded_rem
	  FROM emipocob
	 WHERE no_poliza     = _no_poliza
	   AND no_unidad     = _no_unidad
       AND cod_cobertura IN("01155","00104", "00122"); --Reembolso

	let _audiencia = null;

    if _estatus_audiencia = 0 then
		let _audiencia = "Perdido";
	elif _estatus_audiencia = 1 then  
		let _audiencia = "Ganado";
	elif _estatus_audiencia = 2 then  
		let _audiencia = "Por Definir";
	elif _estatus_audiencia = 3 then  
		let _audiencia = "Proceso Penal";
	elif _estatus_audiencia = 4 then  
		let _audiencia = "Proceso Civil";
	elif _estatus_audiencia = 5 then  
		let _audiencia = "Apelacion";
	elif _estatus_audiencia = 6 then  
		let _audiencia = "Resuelto";
	elif _estatus_audiencia = 7 then  
		let _audiencia = "FUT - Ganado";
	elif _estatus_audiencia = 8 then  
		let _audiencia = "FUT - Responsable";
	end if

	-- Porcentaje de Coaseguro
	SELECT porc_partic_coas
	 INTO  _porc_partic_coas
	 FROM  reccoas
	WHERE  no_reclamo = _no_reclamo
	  AND  cod_coasegur = _cod_coasegur; 

	IF _porc_partic_coas IS NULL THEN
		LET _porc_partic_coas = 0;
	END IF

   	let _sumar_incurrido = 0;
   	let _variacion = 0;

	FOREACH
	 SELECT no_tranrec,
			monto,
			variacion,
			cod_tipotran
	   INTO _no_tranrec,
			_monto_tran,
			_variacion,
			_cod_tipotran
	   FROM rectrmae
	  WHERE no_reclamo  = _no_reclamo
	    AND actualizado = 1

		-- Cambio para que refleje el incurrido neto de acuerdo con el
		-- reaseguro a nivel de transaccion

	   SELECT tipo_transaccion
		 INTO _tipo_transaccion
		 FROM rectitra
		WHERE cod_tipotran = _cod_tipotran;
		
		if _tipo_transaccion = 4 or
		   _tipo_transaccion = 5 or  
		   _tipo_transaccion = 6 or  
		   _tipo_transaccion = 7 then
			let _sumar_incurrido = _monto_tran;
		else
			let _sumar_incurrido = 0.00;
		end if
		
		let _sumar_incurrido = _sumar_incurrido + _variacion;
		let _incurrido_bruto = _sumar_incurrido * _porc_partic_coas / 100;

	end foreach

	let _renglon = 1;
    let _desc_nota1 = null;
    let _desc_nota2 = null;
    let _desc_nota3 = null;
    let _fecha_nota1 = null;
    let _fecha_nota2 = null;
    let _fecha_nota3 = null;


    foreach
		select desc_nota, fecha_nota
		  into _desc_nota, _fecha_nota
		  from recnotas
		 where no_reclamo = _no_reclamo
	  order by fecha_nota desc

      	if _renglon = 1 then
			let _desc_nota1 = _desc_nota;
			let _fecha_nota1 = _fecha_nota;
		elif _renglon = 2 then
			let _desc_nota2 = _desc_nota;
			let _fecha_nota2 = _fecha_nota;
		elif _renglon = 3 then
			let _desc_nota3 = _desc_nota;
			let _fecha_nota3 = _fecha_nota;
		end if
		let _renglon = _renglon + 1;
	end foreach				

    let _transaccion = null;
    let _cod_tipopago = null;
    let _cod_cliente = null;
    let _fecha = null;
    let _monto = null;
    let _tipopago = null;
	let _pagado = null;

    foreach
		select transaccion,
		       cod_tipopago,
		       cod_cliente,
			   fecha,
			   monto
		  into _transaccion,
		       _cod_tipopago,
			   _cod_cliente,
			   _fecha,
			   _monto
		  from rectrmae
		 where no_reclamo = _no_reclamo
		   and cod_tipotran = "004"
		   and actualizado = 1
	  order by no_tranrec desc
	  exit foreach;
	end foreach

   select nombre 
     into _tipopago
	 from rectipag
	where cod_tipopago = _cod_tipopago;

	select nombre into _pagado
	  from cliclien 
	 where cod_cliente = _cod_cliente;


   return _no_tramite, 
          _numrecla,
          _no_documento,
          _ls_ded_col,
          _ls_ded_comp,
          _ls_ded_dan,
          _ls_ded_rem, 
          _asegurado, 
		  _conductor,
          _fecha_siniestro, 
          _fecha_reclamo, 
		  _transaccion,
		  _tipopago,
		  _pagado,
		  _fecha,
		  _monto,
		  _fecha_nota1,
		  _desc_nota1,
		  _fecha_nota2,
		  _desc_nota2,
		  _fecha_nota3,
		  _desc_nota3,
		  _abogado,
          _evento,
          _ajustador, 
		  _audiencia          with resume; 

end foreach


--unload to recibos.txt select no_recibo from tmp_recibos;

end procedure