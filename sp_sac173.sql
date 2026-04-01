-- Detalle de los reclamos para revision contable

-- Creado    : 08/02/2010 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_sac173;

create procedure "informix".sp_sac173(a_periodo char(7))
returning char(20),
          char(10),
		  char(50),
		  date,
		  dec(16,2),
		  dec(16,2),
		  date,
		  char(3),
		  char(50),
		  char(3),
		  char(50),
		  char(5),
		  char(50),
		  decimal(9,6),
		  decimal(9,6),
		  decimal(5,2),
		  char(17),
		  char(17),
		  char(20),
		  char(3),
		  char(50),
		  char(3),
		  char(50),
		  decimal(7,4);

define _nombre_ramo		char(50);
define _nombre_cliente	char(50);
define _nombre_tran		char(50);

define _no_documento	char(20);

define _no_factura		char(10);
define _no_poliza		char(10);
define _cod_cliente		char(10);
define _cod_agente		char(10);
define _no_reclamo		char(10);
define _no_tranrec		char(10);


define _periodo			char(7);
define _periodo2		char(7);

define _no_endoso		char(5);

define _cod_ramo		char(3);
define _cod_tipotran	char(3);

define _tipo_agente		char(1);

define _fecha			date;
define _fecha_anulado	date;

define _prima_suscrita	dec(16,2);
define _prima_neta		dec(16,2);

define _porc_comis_agt  dec(5,2);
define _porc_partic_agt	dec(5,2);

define _n_calculo         char(17);
define _n_clase_cont      char(17);
define _n_tipo_reas       char(20);
define _cod_coasegur      char(3);
define _cod_coasegur2     char(3);
define _porc_partic_coas  decimal(7,4);
define _cod_cobertura     char(5);
define _cod_cober_reas    char(3);
define _cod_contrato      char(5);
define _porc_partic_suma  decimal(9,6);
define _porc_partic_prima decimal(9,6);
define _nombre            char(50);
define _clase_contrato	  char(1);
define _tipo_reaseguro	  char(1);
define _tiene_comision    smallint;
define _porc_comision     decimal(5,2);
define _n_coas2,_n_coas   char(50); 


create temp table tmp_rec(
no_tranrec		  char(10),
cod_coasegur	  char(3)      default null,
porc_partic_coas  decimal(7,4) default 0,
porc_comision     decimal(5,2) default 0,
cod_coasegur2	  char(3)      default null
) with no log;

let _n_coas2 = "";
let _n_coas  = "";

foreach
 select numrecla,
        transaccion,
		fecha,
		periodo,
		monto,
		variacion,
		no_reclamo,
		no_tranrec,
		cod_tipotran
   into _no_documento,
        _no_factura,
		_fecha_anulado,
		_periodo,
		_prima_neta,
		_prima_suscrita,
		_no_reclamo,
		_no_tranrec,
		_cod_tipotran
   from rectrmae
  where cod_compania = "001"
    and actualizado  = 1 	
    and periodo      = a_periodo
	and numrecla     = "14-0509-00009-01"

	select nombre
	  into _nombre_tran
	  from rectitra
	 where cod_tipotran = _cod_tipotran;

	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select cod_ramo,
	       cod_contratante
	  into _cod_ramo,
	       _cod_cliente
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;

	-- Periodo y Fecha

	let _periodo2 = sp_sis39(_fecha_anulado);

	if _periodo = _periodo2 then
		let _fecha = _fecha_anulado;
	elif _periodo > _periodo2 then
		let _fecha = MDY(_periodo[6,7], 1, _periodo[1,4]);
	elif _periodo < _periodo2 then
		let _fecha = sp_sis36(_periodo);
	end if

	foreach

		select cod_coasegur,
			   porc_partic_coas								  
		  into _cod_coasegur,								  
		       _porc_partic_coas
		  from reccoas										  
		 where no_reclamo = _no_reclamo						  

		insert into tmp_rec(no_tranrec,cod_coasegur,porc_partic_coas)
		values (_no_tranrec, _cod_coasegur,_porc_partic_coas);


	end foreach

	foreach

        select cod_cobertura
          into _cod_cobertura
          from rectrcob
         where no_tranrec = _no_tranrec

        exit foreach;

    end foreach
                       
    select cod_cober_reas
      into _cod_cober_reas
      from prdcober
     where cod_cobertura = _cod_cobertura;

	foreach
		select cod_contrato,
			   porc_partic_suma,
			   porc_partic_prima
		  into _cod_contrato,
		       _porc_partic_suma,
			   _porc_partic_prima
		  from rectrrea
		 where no_tranrec = _no_tranrec

        select nombre,
		       clase_contrato,
			   tipo_reaseguro
		  into _nombre,
		       _clase_contrato,				 --P=Proporcional, N=No Proporcional,F=Facultativo
			   _tipo_reaseguro				 --P=Ocurrencia de Perdida,O=Origen de Poliza
		  from reacomae
		 where cod_contrato = _cod_contrato;

		if _clase_contrato = "P" then
			let _n_clase_cont = "PROPORCIONAL";
		elif  _clase_contrato = "N" then
			let _n_clase_cont = "NO PROPORCIONAL";
		elif  _clase_contrato = "F" then
			let _n_clase_cont = "FACULTATIVO";
		end if

		if _tipo_reaseguro = "P" then
			let _n_tipo_reas  = "OCURRENCIA DE PERDIDA";
		elif  _tipo_reaseguro = "O" then
			let _n_tipo_reas = "ORIGEN DE POLIZA";
		end if


		select tiene_comision
		  into _tiene_comision					 --0=no tiene, 1=Por contrato, 2=Por Reasegurador
		  from reacocob
		 where cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;

		if _tiene_comision = 0 then
			let _n_calculo = "NO TIENE";
		elif _tiene_comision = 1 then
			let _n_calculo = "POR CONTRATO";
		elif _tiene_comision = 2 then
			let _n_calculo = "POR REASEGURADOR";
		end if

	    foreach

			select porc_comision,
			       cod_coasegur
			  into _porc_comision,
			       _cod_coasegur2
			  from reacoase
			 where cod_contrato   = _cod_contrato
			   and cod_cober_reas = _cod_cober_reas

			insert into tmp_rec(no_tranrec,porc_comision,cod_coasegur2)
			values (_no_tranrec, _porc_comision,_cod_coasegur2);


        end foreach

		return _no_documento,
		       _no_factura,
			   _nombre_cliente,
			   _fecha_anulado,
			   _prima_neta,
			   _prima_suscrita,
			   _fecha,
			   _cod_ramo,
			   _nombre_ramo,
			   _cod_tipotran,
			   _nombre_tran,
			   _cod_contrato,
			   _nombre,
			   _porc_partic_suma,
			   _porc_partic_prima,
			   0,		      --comision reasegurador
			   _n_calculo,	  --calculo comision
			   _n_clase_cont, --clase contrato
			   _n_tipo_reas,  --tipo reaseguro
			   '',			  --cod coasegur
			   '',			  --nombre empresa coasegur
			   '',
			   '',
			   0
			   with resume;

		foreach

			select porc_comision,
			       cod_coasegur2,
				   porc_partic_coas,
				   cod_coasegur
			  into _porc_comision,
			       _cod_coasegur2,
				   _porc_partic_coas,
				   _cod_coasegur
			  from tmp_rec

		   if _cod_coasegur2 is not null then
				select nombre
				  into _n_coas2
				  from emicoase
				 where cod_coasegur = _cod_coasegur2;
		   else
				let _n_coas2 = "";
				let _porc_comision = 0;
		   end if

		   if _cod_coasegur is not null then
			    select nombre
				  into _n_coas
				  from emicoase
				 where cod_coasegur = _cod_coasegur;
		   else
				let _n_coas = "";
				let _porc_partic_coas = 0;

		   end if

			return _no_documento,
				   _no_factura,
				   _nombre_cliente,
				   _fecha_anulado,
				   _prima_neta,
				   _prima_suscrita,
				   _fecha,
				   _cod_ramo,
				   _nombre_ramo,
				   _cod_tipotran,
				   _nombre_tran,
				   _cod_contrato,
				   _nombre,
				   _porc_partic_suma,
				   _porc_partic_prima,
				   _porc_comision,		--comision reasegurador
				   _n_calculo,			--calculo comision
				   _n_clase_cont,		--clase contrato
				   _n_tipo_reas,		--tipo reaseguro
				   _cod_coasegur2,		--cod_coasegur
				   _n_coas2,			--nombre empresa reaseguradora
				   _cod_coasegur,
				   _n_coas,				--coaseguradora
				   _porc_partic_coas	--participacion
				   with resume;

		end foreach

		delete from tmp_rec;

	end foreach

end foreach

drop table tmp_rec;

end procedure
