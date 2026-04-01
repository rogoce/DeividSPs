-- Procedure que Actualiza los comprobantes de Mayor

-- Creado: 03/02/2007 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_sac38;

create procedure "informix".sp_sac38(
a_notrx 	integer,
a_usuario	char(15)
) returning integer,
            char(100);

define _par_mesfiscal	char(2);
define _par_anofiscal	char(4);

define _per_status 		char(1);
define _est_nivel		char(1);

define _trx1_fecha 		date;
define _trx1_comprob	char(8);
define _trx1_ccosto     char(3);
define _trx1_tipo	    char(2);
define _trx1_origen	    char(3);
define _trx1_concepto   char(3);
define _trx1_descrip    char(50);
define _trx1_moneda     char(2);
define _trx1_usuario    char(15);
define _trx1_fechacap   datetime year to second;

define _trx2_linea		integer;
define _trx2_debito		dec(16,2);
define _trx2_credito	dec(16,2);
define _trx2_cuenta		char(12);

define _trx3_auxiliar	char(5);
define _trx3_debito		dec(16,2);
define _trx3_credito	dec(16,2);
define _trx3_cuenta		char(12);

define _cta_recibe		char(1);
define _cta_nivel		char(1);
define _cta_tipo        char(2);
define _cta_auxiliar	char(1);

define _periodo			char(7);
define _mes				char(2);
define _ano				char(4);
define _cantidad		smallint;
define _ciclo			smallint;
define _indice			smallint;
define _cuenta			char(12);
define _pos_final		smallint;
define _pos_mayor		smallint;
define _no_registro		integer;
define _no_linea		integer;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

begin work;

begin
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc;
end exception

select par_mesfiscal,
	   par_anofiscal
  into _par_mesfiscal,
   	   _par_anofiscal
  from cglparam;

select trx1_fecha,
       trx1_comprobante,
	   trx1_ccosto,
	   trx1_tipo,
	   trx1_concepto,
	   trx1_descrip,
	   trx1_moneda,
	   trx1_usuario,
	   trx1_fechacap,
	   trx1_origen
  into _trx1_fecha,
       _trx1_comprob,
	   _trx1_ccosto,
	   _trx1_tipo,
	   _trx1_concepto,
	   _trx1_descrip,
	   _trx1_moneda,
	   _trx1_usuario,
	   _trx1_fechacap,
	   _trx1_origen
  from cgltrx1
 where trx1_notrx = a_notrx;

let _periodo = sp_sis39(_trx1_fecha);
let _mes     = _periodo[6,7];
let _ano     = _periodo[1,4];

select est_posfinal
  into _pos_mayor
  from cglestructura
 where est_nivel = 5;

-- Verifica el Periodo

select per_status
  into _per_status
  from cglperiodo
 where per_ano = _ano
   and per_mes = _mes;

if _per_status is null then
	return 1, "El Periodo " || _periodo ||  " a Mayorizar No Esta Definido en cglperiodo";
end if

if _per_status = "C" then
	return 1, "El Periodo " || _periodo ||  " a Mayorizar esta Cerrado";
end if

if _par_anofiscal > _ano then
	return 1, "En el Comprobante " || _trx1_comprob || " el Periodo " || _ano || " Esta Cerrado";
end if

-- Verifica Sumatoria de Montos

select sum(trx2_debito),
       sum(trx2_credito)
  into _trx2_debito,
       _trx2_credito
  from cgltrx2
 where trx2_notrx = a_notrx;
 
 if _trx2_debito <> _trx2_credito then
	return 1, "El Comprobante " || _trx1_comprob ||  " No Esta en Balance";
 end if 

-- Verificaciones de las Cuentas

foreach
 select trx2_cuenta,
		trx2_debito,
		trx2_credito,
		trx2_linea
   into _trx2_cuenta,		
		_trx2_debito,
		_trx2_credito,
		_trx2_linea
   from cgltrx2
  where trx2_notrx = a_notrx

	if length(_trx2_cuenta) > _pos_mayor then
		return 1, "En el Comprobante " || _trx1_comprob || " La Cuenta " || _trx2_cuenta || " Es Muy Grande";
	end if

	select cta_recibe,
	       cta_nivel,
		   cta_tipo,
		   cta_auxiliar
	  into _cta_recibe,
	       _cta_nivel,
		   _cta_tipo,
		   _cta_auxiliar
	  from cglcuentas
	 where cta_cuenta = _trx2_cuenta; 

	if _cta_recibe is null then
		return 1, "En el Comprobante " || _trx1_comprob || " La Cuenta " || _trx2_cuenta || " No Esta Creada";
	end if

	if _cta_recibe = "N" then
		return 1, "En el Comprobante " || _trx1_comprob || " La Cuenta " || _trx2_cuenta || " No Recibe Movimiento";
	end if

	select est_nivel
	  into _est_nivel
	  from cglestructura
	 where est_nivel = _cta_nivel;
	 
	if _est_nivel is null then
		return 1, "En el Comprobante " || _trx1_comprob || " La Cuenta " || _trx2_cuenta || " No Existe el Nivel";
	end if

	for _indice = _cta_nivel to 1 step -1 

		select est_posfinal
		  into _pos_final
		  from cglestructura
		 where est_nivel = _indice;

		let _cuenta = substring(_trx2_cuenta from 1 for _pos_final);

		select cta_recibe
		  into _cta_recibe
		  from cglcuentas
		 where cta_cuenta = _cuenta; 

		if _cta_recibe is null then
			return 1, "En el Comprobante " || _trx1_comprob || " La Cuenta " || _cuenta || " No Esta Creada";
		end if

	end for

	if _cta_auxiliar = "S" then 

		-- Validacion de Montos
				
        select sum(trx3_debito), 
        	   sum(trx3_credito) 
	      into _trx3_debito, 
           	   _trx3_credito
          from cgltrx3
         where trx3_notrx     = a_notrx
		   and trx3_tipo      = _trx1_tipo
	       and trx3_lineatrx2 = _trx2_linea;

		if _trx3_debito is null then
			let _trx3_debito = 0.00;
		end if

		if _trx3_credito is null then
			let _trx3_credito = 0.00;
		end if

		if _trx2_debito <> _trx3_debito then
			return 1, "En el Comprobante " || _trx1_comprob || " Linea " || _trx2_linea || " Auxiliar Desbalanceado";
		end if

		if _trx2_credito <> _trx3_credito then
			return 1, "En el Comprobante " || _trx1_comprob || " Linea " || _trx2_linea || " Auxiliar Desbalanceado";
		end if

		-- Validacion de Valor del Auxiliar

        select count(*) 
	      into _cantidad
          from cgltrx3
         where trx3_notrx     = a_notrx
		   and trx3_tipo      = _trx1_tipo
	       and trx3_lineatrx2 = _trx2_linea
	       and trx3_auxiliar  is null;

		if _cantidad <> 0 then
			return 1, "En el Comprobante " || _trx1_comprob || " Linea " || _trx2_linea || " Falta el Auxiliar";
		end if

	end if

end foreach

-- Actualizacion de Saldos

foreach
 select trx2_cuenta,
		trx2_debito,
		trx2_credito,
		trx2_linea
   into _trx2_cuenta,		
		_trx2_debito,
		_trx2_credito,
		_trx2_linea
   from cgltrx2
  where trx2_notrx = a_notrx

	select cta_nivel,
	       cta_auxiliar
	  into _cta_nivel,
	       _cta_auxiliar
	  from cglcuentas
	 where cta_cuenta = _trx2_cuenta; 

	-- Saldos del Mayor

	for _indice = _cta_nivel to 1 step -1 

		select est_posfinal
		  into _pos_final
		  from cglestructura
		 where est_nivel = _indice;

		let _cuenta = substring(_trx2_cuenta from 1 for _pos_final);

		select count(*)
		  into _cantidad
		  from cglsaldodet
		 where sldet_tipo	= _trx1_tipo
		   and sldet_cuenta = _cuenta
		   and sldet_ccosto	= _trx1_ccosto
		   and sldet_ano 	= _ano;

		if _cantidad = 0 then

			insert into cglsaldoctrl
			values (_trx1_tipo, _cuenta, _trx1_ccosto, _ano, "0");
			
			for _ciclo = 1 to 14
				
				insert into cglsaldodet
				values (_trx1_tipo, _cuenta, _trx1_ccosto, _ano, _ciclo, 0, 0, 0);

			end for 

		end if

		update cglsaldodet
		   set sldet_debtop  = 	sldet_debtop + _trx2_debito,
		       sldet_cretop  =	sldet_cretop - _trx2_credito,
			   sldet_saldop  = 	sldet_saldop + _trx2_debito - _trx2_credito
		 where sldet_tipo	 = _trx1_tipo
		   and sldet_cuenta  = _cuenta
		   and sldet_ccosto	 = _trx1_ccosto
		   and sldet_ano 	 = _ano
		   and sldet_periodo = _mes;
		
	end for

	-- Saldos de los Auxiliares

	if _cta_auxiliar = "S" then 

		foreach
         select trx3_auxiliar,
		        trx3_debito,
				trx3_credito
	       into _trx3_auxiliar,
		        _trx3_debito,
				_trx3_credito
           from cgltrx3
          where trx3_notrx     = a_notrx
		    and trx3_tipo      = _trx1_tipo
	        and trx3_lineatrx2 = _trx2_linea

			select count(*)
			  into _cantidad
			  from cglsaldoaux1
			 where sld1_tipo	= _trx1_tipo
			   and sld1_cuenta  = _trx2_cuenta
			   and sld1_tercero	= _trx3_auxiliar
			   and sld1_ano 	= _ano;

			if _cantidad = 0 then

				insert into cglsaldoaux
				values (_trx1_tipo, _trx2_cuenta, _trx3_auxiliar, _ano, "0");
				
				for _ciclo = 1 to 14
					
					insert into cglsaldoaux1
					values (_trx1_tipo, _trx2_cuenta, _trx3_auxiliar, _ano, _ciclo, 0, 0, 0);

				end for 

			end if

			update cglsaldoaux1 
			   set sld1_debitos  = 	sld1_debitos  + _trx3_debito,
			       sld1_creditos =	sld1_creditos - _trx3_credito,
				   sld1_saldo    = 	sld1_saldo    + _trx3_debito - _trx3_credito
			 where sld1_tipo	 = _trx1_tipo
			   and sld1_cuenta   = _trx2_cuenta
			   and sld1_tercero	 = _trx3_auxiliar
			   and sld1_ano 	 = _ano
			   and sld1_periodo  = _mes;

		end foreach

	end if

end foreach

-- Actualizacion Historico Cuentas

foreach
 select trx2_linea,
		trx2_cuenta,
		trx2_debito,
		trx2_credito
   into	_trx2_linea,
		_trx2_cuenta,
		_trx2_debito,
		_trx2_credito
   from cgltrx2
  where trx2_notrx = a_notrx

	-- Contador de Transacciones Resumen

	call sp_sac54(_trx1_ccosto, "CGL", "03", "para_resumen")
	     returning _error, _error_desc, _no_registro;

	if _error <> 0 then
		return _error, _error_desc;
	end if

	insert into cglresumen(
	res_noregistro,
	res_tipo_resumen,
	res_notrx,
	res_comprobante,
	res_fechatrx,
	res_tipcomp,
	res_ccosto,
	res_descripcion,
	res_moneda,
	res_cuenta,
	res_debito,
	res_credito,
	res_usuariocap,
	res_usuarioact,
	res_fechacap,
	res_fechaact,
	res_origen,
	res_status,
	res_tabla
	)
	values(
	_no_registro,
	_trx1_tipo,
	a_notrx,
	_trx1_comprob,
	_trx1_fecha,
	_trx1_concepto,
	_trx1_ccosto,
	_trx1_descrip,
	_trx1_moneda,
	_trx2_cuenta,
	_trx2_debito,
	_trx2_credito,
	_trx1_usuario,
	a_usuario,
	_trx1_fechacap,
	current,
	_trx1_origen,
	"C",
	""
	);

	-- Actualizacion Historico Auxiliares

	let _no_linea = 0;

	foreach
	 select	trx3_cuenta,
			trx3_debito,
			trx3_credito,
			trx3_auxiliar
	   into	_trx3_cuenta,
			_trx3_debito,
			_trx3_credito,
			_trx3_auxiliar
	   from cgltrx3
	  where trx3_notrx     = a_notrx
		and trx3_lineatrx2 = _trx2_linea

		let _no_linea = _no_linea + 1;

		insert into cglresumen1(
		res1_noregistro,
		res1_linea,
		res1_tipo_resumen,
		res1_comprobante,
		res1_cuenta,
		res1_auxiliar,
		res1_debito,
		res1_credito,
		res1_origen
		)
		values(
		_no_registro,
		_no_linea,
		_trx1_tipo,
		_trx1_comprob,
		_trx3_cuenta,
		_trx3_auxiliar,
		_trx3_debito,
		_trx3_credito,
		_trx1_origen
		);

	end foreach

end foreach

-- Eliminacion de registros procesados

delete from cgltrx3 where trx3_notrx = a_notrx;
delete from cgltrx2 where trx2_notrx = a_notrx;
delete from cgltrx1 where trx1_notrx = a_notrx;

end 

rollback work;

return 0, "Actualizacion Exitosa";

end procedure

























							 