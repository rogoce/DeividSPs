-- Procedure depuera los codigos de los auxiliares
-- 
-- Creado    : 12/12/2012 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac225;		

create procedure "informix".sp_sac225(
a_cod_aux_old	char(5),
a_cod_aux_new	char(5)
) returning integer,
            char(100);


define _cod_cliente	char(10);
define _cod_cuenta	char(25);
define _cantidad	smallint;

define _no_registro	integer;
define _linea		integer;
define _tipo		char(2);
define _ano			char(4);
define _monto		dec(16,2);
define _debito		dec(16,2);
define _credito		dec(16,2);
define _periodo		smallint;

define _error		integer;
define _error_isam	integer;
define _error_desc	char(100);

begin work;

begin
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_isam || " " || _error_desc;
end exception

if a_cod_aux_old[1,1] = "A" then
	rollback work;
	return 1, "El Auxiliar " || a_cod_aux_old || " Tiene Enlace con la Tabla de Agentes ";
end if  

let _cod_cliente = null;

select ter_codcliente
  into _cod_cliente
  from cglterceros
 where ter_codigo = a_cod_aux_old;

if _cod_cliente is not null then
	rollback work;
	return 1, "El Auxiliar " || a_cod_aux_old || " Tiene Enlace con la Tabla de Clientes " || _cod_cliente;
end if  

-- cglauxiliar

{
foreach
 select aux_cuenta
   into _cod_cuenta
   from cglauxiliar
  where aux_tercero = a_cod_aux_old

	select count(*)
	  into _cantidad
	  from cglauxiliar
	 where aux_cuenta  = _cod_cuenta
	   and aux_tercero = a_cod_aux_new;

	if _cantidad = 0 then

		insert into cglauxiliar(
		aux_cuenta,
		aux_tercero,
		aux_pctreten,
		aux_saldoret,
		aux_corriente,
		aux_30dias,
		aux_60dias,
		aux_90dias,
		aux_120dias,
		aux_150dias,
		aux_ultimatrx,
		aux_ultimodcmto,
		aux_observacion
		)
		select 
		_cod_cuenta,
		a_cod_aux_new,
		aux_pctreten,
		aux_saldoret,
		aux_corriente,
		aux_30dias,
		aux_60dias,
		aux_90dias,
		aux_120dias,
		aux_150dias,
		aux_ultimatrx,
		aux_ultimodcmto,
		aux_observacion
		from cglauxiliar
	   where aux_cuenta  = _cod_cuenta
	     and aux_tercero = a_cod_aux_old;

		return 1, "Insertar " || _cod_cuenta || " " || a_cod_aux_new with resume;

	end if

end foreach
}
  
-- cglresumen1

{
foreach 
 select res1_noregistro,
		res1_linea
   into _no_registro,
		_linea
   from cglresumen1
  where res1_auxiliar = a_cod_aux_old

		update cglresumen1
		   set res1_auxiliar   = a_cod_aux_new
		 where res1_noregistro = _no_registro
		   and res1_linea      = _linea;

		return 1, _no_registro || " " || _linea || " " || a_cod_aux_old || " " ||  a_cod_aux_new with resume;

end foreach
--}

-- cglsaldoaux

{
foreach
 select sld_tipo,
        sld_cuenta,
		sld_ano,
		sld_incioano
   into _tipo,
        _cod_cuenta,
		_ano,
		_monto
   from cglsaldoaux
  where sld_tercero = a_cod_aux_old

	select count(*)
	  into _cantidad
	  from cglsaldoaux
	 where sld_tipo    = _tipo
	   and sld_cuenta  = _cod_cuenta
	   and sld_tercero = a_cod_aux_new
	   and sld_ano     = _ano;

	if _cantidad = 0 then

		insert into cglsaldoaux(
		sld_tipo,
		sld_cuenta,
		sld_tercero,
		sld_ano,
		sld_incioano
		)
		select 
		sld_tipo,
		sld_cuenta,
		a_cod_aux_new,
		sld_ano,
		sld_incioano
         from cglsaldoaux
	    where sld_tipo    = _tipo
	      and sld_cuenta  = _cod_cuenta
	      and sld_tercero = a_cod_aux_old
	      and sld_ano     = _ano;


		return 1, "Insertar " || _tipo || " " || _cod_cuenta || " " || a_cod_aux_new || " " || _ano || " " || _monto  with resume;
	
	else

		update cglsaldoaux
		   set sld_incioano = sld_incioano + _monto
	     where sld_tipo     = _tipo
	       and sld_cuenta   = _cod_cuenta
	       and sld_tercero  = a_cod_aux_new
	       and sld_ano      = _ano;
		  
	
		return 1, "Actualizar " || _tipo || " " || _cod_cuenta || " " || a_cod_aux_new || " " || _ano || " " || _monto  with resume;
	
	end if		

end foreach
--}

-- cglsaldoaux1

--{												  
foreach
 select sld1_tipo,
        sld1_cuenta,
		sld1_ano,
		sld1_periodo,
		sld1_debitos,
		sld1_creditos,
		sld1_saldo
   into _tipo,
        _cod_cuenta,
		_ano,
		_periodo,
		_debito,
		_credito,
		_monto
   from cglsaldoaux1
  where sld1_tercero = a_cod_aux_old

	select count(*)
	  into _cantidad
	  from cglsaldoaux1
	 where sld1_tipo    = _tipo
	   and sld1_cuenta  = _cod_cuenta
	   and sld1_tercero = a_cod_aux_new
	   and sld1_ano     = _ano
	   and sld1_periodo = _periodo;


	if _cantidad = 0 then



		return 1, "Insertar " || _tipo || " " || _cod_cuenta || " " || a_cod_aux_new || " " || _ano || " " || _monto  with resume;
	
	else
	
		return 1, "Actualizar " || _tipo || " " || _cod_cuenta || " " || a_cod_aux_new || " " || _ano || " " || _monto  with resume;
	
	end if		

end foreach
--}

-- Eliminar cglsaldoaux

--delete from cglsaldoaux
-- where sld_tercero = a_cod_aux_old;

-- Eliminar cglauxiliar

--delete from cglauxiliar
-- where aux_tercero = a_cod_aux_old;


end

rollback work;

return 0, "Actualizacion Exitosa";

end procedure
