--- Renovacion Automatica.
--- Creado 02/03/2009 por Armando Moreno

drop procedure sp_cob248a;

create procedure "informix".sp_cob248a()
returning char(20),decimal(16,2),decimal(16,2),decimal(16,2);

begin

define v_documento  	char(20);
define v_factura    	char(10);
define v_renovar    	smallint;
define v_cod_renovar 	smallint;
define v_cod_no_renovar char(3);
define _cod_ramo        char(3);
define _no_poliza       char(10);
define v_vigencia_inic  date;
define _vig_inic_ult    date;
define v_vigencia_fin   date;
define v_tipo       	char(3);
define v_saldo      	decimal(16,2);
define v_cant       	smallint;
define v_cantidad   	smallint;
define v_incurrido  	decimal(16,2);
define v_pagos      	decimal(16,2);
define v_tot_pagos  	decimal(16,2);
define _suma_asegurada	decimal(16,2);
define _perd_total  	smallint;
define _todas_perdida  	smallint;
define _cod_compania   	char(3);
define _codigo_agencia	char(3);
define _cod_sucursal   	char(3);
define _centro_costo   	char(3);
define _usuario      	char(8);
define _cnt			  	smallint;
define _cantidad	  	smallint;
define _cod_agente      char(5);
define _porc_partic  	decimal(5,2);
define _vig_final		date;
define _cod_tipoprod    char(3);
define _cod_grupo       char(5);
define _salir           smallint;
define _cod_subramo     char(3);
define _fecha           date;
define _cod_manzana     char(15);
define _cod_asegurado   char(10);
define _fecha_aniversario date;
define _edad            integer;
define _no_unidad       char(5);
define _activo          smallint;
define _cod_acreedor    char(5);
define _ano_auto        smallint;
define _cod_cobertura   char(5);
define _estatus         smallint;
define _prima_bruta     decimal(16,2);
define _diezporc	    decimal(16,2);
define _saldo           decimal(16,2);
define _renglon         smallint;
define _reg             integer;
define _error           smallint;
define _usu_cob         char(8);
define _porcentaje      integer;
define _declarativa     smallint;
define _gerarquia       smallint;
define _cod_formapag    char(3);
define _tipo_forma      smallint;
define li_cnt           smallint;
define ls_usuario       char(8);
define _serie           integer;
define _no_p            char(10);
define _vig_ini         date;
define _vig_fin         date;
define _usuario_cobros  char(8);
define _cod_contr       char(10);
define _bander          smallint;

--SET DEBUG FILE TO "sp_cob248.trc"; 
--TRACE ON;                                                                

set isolation to dirty read;

let _fecha           = current;
let v_pagos          = 0;
let v_incurrido      = 0;
let v_cantidad       = 0;
let v_saldo          = 0;
let v_renovar        = 0;
let v_cod_renovar    = 0;
let _salir 			 = 0;
let v_factura        = NULL;
let v_cod_no_renovar = NULL;
let _prima_bruta     = 0;
let _ano_auto        = 0;
let _porcentaje      = 10;
let li_cnt           = 0;

select usuario_cobros
  into _usuario_cobros
  from emirepar;

foreach

	select no_poliza,
	       no_documento,
		   estatus
	  into _no_poliza,
	       v_documento,
		   _estatus
	  from emirepo
	 where (user_added = _usuario_cobros
	    or user_cobros = _usuario_cobros)
   	   and estatus not in(5,9)

    --and no_documento[1,2] not in ("13","14","17")

	select count(*)
	  into li_cnt
	  from emideren
	 where no_poliza = _no_poliza;

    select cod_formapag,prima_bruta,cod_ramo,cod_contratante
	  into _cod_formapag,_prima_bruta,_cod_ramo,_cod_contr
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo = "002" then
	else
		continue foreach;
	end if

	SELECT tipo_forma
	  INTO _tipo_forma
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	let _saldo = 0;
   	let _saldo = sp_cob115b('001','001',v_documento,'');

	if _tipo_forma = 2 or _tipo_forma = 3 or _tipo_forma = 4 then	--2=visa,3=desc salario,4=ach

		select usuario_cobros,
		       saldo_elect
		  into _usu_cob,
		       _porcentaje
		  from emirepar;

	else
		
		select usuario_cobros,
		       saldo_porc
		  into _usu_cob,
		       _porcentaje
		  from emirepar;

	end if
	foreach
			select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = _no_poliza

			if _cod_agente = "00218" then  --kam panama
				exit foreach;
			end if
	end foreach
	if _cod_agente = "00218" then
		let _bander = 0;
		select count(*)
		  into _bander
		  from emipouni
		 where no_poliza     = _no_poliza
		   and cod_asegurado = "84250";  --Pacific Leasing

		if _bander > 0 or _cod_contr = "84250" then
			if _cod_agente = "00218" then  --Es Pacific Leasing y corredor Kam Panama, porc debe ser 20% sol. por Nixia Morales 29/09/2011, Armando.
				let _porcentaje = 20;
			end if
		end if
	else
		continue foreach;
	end if

	let _diezporc = 0;
	let _diezporc = _prima_bruta * (_porcentaje / 100);
    let _usu_cob  = trim(_usu_cob);

	let _saldo    = _saldo;
	let _diezporc = _diezporc;

	if _saldo is null then
		let _saldo = 0;
	end if
   	if _saldo > _diezporc then
   		continue foreach;
   	else

	  	select count(*)
		  into li_cnt
		  from emideren
		 where no_poliza = _no_poliza
		   and renglon   = 11;

		if li_cnt > 0 then
			return v_documento,_saldo,_diezporc,_prima_bruta with resume;
		end if
	end if

end foreach
end
end procedure;
