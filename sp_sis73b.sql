-- Depuracion de la tabla de Clientes
-- Creado    : 06/04/2005 - Autor: Demetrio Hurtado Almanza 
-- Modificado: Henry utilizado para duplicidad de clientes

drop procedure sp_sis73b;
create procedure sp_sis73b(
a_cod_errado	char(10), 
a_cod_correcto 	char(10),
a_user		    char(8),
a_cod_agrupa    char(10),
a_direccion	    char(55),
a_tel		    char(12),
a_nacimiento	date
) returning integer,
            char(100);

define _tiempo		    datetime year to fraction(5);

define _error		    integer;
define _error_isam	    integer;
define _error_desc	    char(100);
define x_cod_errado	    char(10);
define x_cod_correcto 	char(10);
define _no_reclamo		char(10);
define _por_vencer		dec(16,2);
define _exigible 		dec(16,2);
define _corriente 		dec(16,2);
define _monto_30 		dec(16,2);
define _monto_60 		dec(16,2);
define _monto_80 		dec(16,2);
define _saldo 			dec(16,2);
define _cnt_corr        smallint;
define _cnt_err         smallint;
define _date_changed_corr date;
define _date_changed_err  date;

let _tiempo = current;
SET LOCK MODE TO WAIT 5;

--set debug file to "sp_sis73b.trc";
--trace on;

let x_cod_errado   = a_cod_errado;
let	x_cod_correcto = a_cod_correcto;
--begin work; Esto no va, ya que se controla en powerbuilder.

begin
on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error, _error_desc;
end exception

--select estado
-- into _estatus
--  from clideagr
-- where cod_agrupa = a_cod_agrupa;

--if _estatus = 1 then
--	return 1, "Este Registro Ya Fue Procesado";
--end if
--agregado para insertar los clientes que se eliminan en una tabla para que yo seguro la pueda consultar
{
CALL sp_yos15(a_cod_errado,a_cod_correcto) returning _error, _error_desc;
IF _error <> 0 THEN
	RETURN  _error, _error_desc;
END IF
}
-- --- --- -- --- --- --  ---- --- 
update bkcavica
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

update chqchmae
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

update cliclicl
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

update clicolat
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

update cobavica
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

update cobaviso			---
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

update cobca90p
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

update cobcacam
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

update cobcahis
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

update cobcampl
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

update cobforpaexm
   set cod_agente   = a_cod_correcto
 where cod_agente   = a_cod_errado
   and tipo_formato = 3;

update cobpaex0
   set cod_agente   = a_cod_correcto
 where cod_agente   = a_cod_errado
   and tipo_formato = 3;

-- 
drop table if exists tmp_hijo;
select * 
  from cobcapen
 where cod_cliente in (a_cod_errado,a_cod_correcto)
  into temp tmp_hijo;
 
delete from cobcapen
 where cod_cliente in (a_cod_errado,a_cod_correcto);

let _por_vencer = 0;
let _exigible   = 0;
let _corriente  = 0;
let _monto_30   = 0;
let _monto_60   = 0;
let _monto_80   = 0;
let _saldo      = 0;

select sum(por_vencer),sum(exigible),sum(corriente),sum(monto_30),sum(monto_60),sum(monto_90),sum(saldo)
  into _por_vencer,_exigible,_corriente,_monto_30,_monto_60,_monto_80,_saldo
  from tmp_hijo where cod_cliente in (a_cod_errado,a_cod_correcto);

insert into cobcapen
select a_cod_correcto,hora,cod_cobrador,nuevo,dia,_por_vencer,_exigible,_corriente,_monto_30,_monto_60,_monto_80,_saldo  
  from tmp_hijo where cod_cliente in (a_cod_correcto);

drop table tmp_hijo;
--

update cobcatmp
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

begin
	on exception in(-268)
		
		
		delete from cobcatmp3
			  where cod_pagador = a_cod_errado;
	end exception	

	update cobcatmp3						  
	   set cod_pagador = a_cod_correcto
	 where cod_pagador = a_cod_errado;
end

update cobcuhab
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

update cobcupag
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

update cobcutmp
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

update cobcutra
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

update cobgesti
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

update cobgesti2
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

update cobredet
   set cod_recibi_de = a_cod_correcto
 where cod_recibi_de = a_cod_errado;

update cobruhis
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

update cobruter
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

update cobruter1
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

update cobruter2
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

update diariobk
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

update emibenef
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

select * 
  from emidepen
 where cod_cliente in (a_cod_errado)
  into temp tmp_hijo;

update tmp_hijo
   set cod_cliente = a_cod_correcto;

insert into emidepen
select *
  from tmp_hijo;

update emiprede	 --
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;
 
delete from emidepen
 where cod_cliente in (a_cod_errado);

drop table tmp_hijo;
{update emidepen
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;}

update emipomae
   set cod_contratante = a_cod_correcto
 where cod_contratante = a_cod_errado;

update emipomae
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

BEGIN
ON EXCEPTION IN(-244,-243)  
END EXCEPTION
	update emiporen
	   set cod_contratante = a_cod_correcto
	 where cod_contratante = a_cod_errado;
END 

BEGIN
ON EXCEPTION IN(-244,-243)  
END EXCEPTION
	update emiporen
   	   set cod_pagador = a_cod_correcto
 	 where cod_pagador = a_cod_errado;
END

update emipouni	  
   set cod_asegurado = a_cod_correcto
 where cod_asegurado = a_cod_errado;

update emipouni	  --
   set cod_doctor  = a_cod_correcto
 where cod_doctor  = a_cod_errado;

update emireaut	 --
   set cod_asegurado = a_cod_correcto
 where cod_asegurado = a_cod_errado;

update endbenef		--
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

update endeduni		--
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

update endmoase	   --
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

update recacuan		 ---
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

update recacusu	   ----
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

update recacuvi	   --- 
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

update recdeacu		--
   set cod_reclamante = a_cod_correcto
 where cod_reclamante = a_cod_errado;

update recordma		--
   set cod_proveedor = a_cod_correcto
 where cod_proveedor = a_cod_errado;

update recpcota		-- 
   set cod_proveedor = a_cod_correcto
 where cod_proveedor = a_cod_errado;

update recprove	   --
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

update recrcmae	   --
   set cod_asegurado = a_cod_correcto
 where cod_asegurado = a_cod_errado;

update recrcmae	   --
   set cod_conductor = a_cod_correcto
 where cod_conductor = a_cod_errado;

update recrcmae	  --
   set cod_doctor = a_cod_correcto
 where cod_doctor = a_cod_errado;

update recrcmae	  ---
   set cod_hospital = a_cod_correcto
 where cod_hospital = a_cod_errado;

update recrcmae	  --
   set cod_reclamante = a_cod_correcto
 where cod_reclamante = a_cod_errado;

update recrcmae	 --
   set cod_taller = a_cod_correcto
 where cod_taller = a_cod_errado;

update recrcoma	  --
   set cod_taller = a_cod_correcto
 where cod_taller = a_cod_errado;

update recrcoma	  --
   set cod_tercero = a_cod_correcto
 where cod_tercero = a_cod_errado;
 
 update recterce
   set cod_conductor = a_cod_correcto
 where cod_conductor = a_cod_errado;
 
 update prov_agt
    set cod_contratante = a_cod_correcto
  where cod_contratante = a_cod_errado;
 
BEGIN
ON EXCEPTION IN(-268,-243)
	foreach
		select no_reclamo
		  into _no_reclamo
		  from recterce
		 where no_reclamo in (select no_reclamo from recterce where cod_tercero = a_cod_correcto)
		   and cod_tercero in (a_cod_errado)
		   
		delete from recterce
		 where no_reclamo = _no_reclamo
		   and cod_tercero = a_cod_errado;
	end foreach

	update recterce	--
	   set cod_tercero = a_cod_correcto
	 where cod_tercero = a_cod_errado;

END EXCEPTION

select * 
  from recterdoc
 where cod_tercero in (a_cod_errado)
  into temp tmp_hijo;

update tmp_hijo
   set cod_tercero = a_cod_correcto;

delete from recterdoc
 where cod_tercero in (a_cod_errado);
 
update recterce	--
   set cod_tercero = a_cod_correcto
 where cod_tercero = a_cod_errado;

insert into recterdoc
select *
  from tmp_hijo;
 
drop table tmp_hijo;

END


BEGIN
ON EXCEPTION IN(-244,-243)  
END EXCEPTION
update rectrmae
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;
END 

BEGIN
ON EXCEPTION IN(-244,-243)  
END EXCEPTION
update rectrmae
   set cod_proveedor = a_cod_correcto
 where cod_proveedor = a_cod_errado;
END 

--update tmp_cartadet	-- no existe esta tabla
--   set cod_cliente = a_cod_correcto
-- where cod_cliente = a_cod_errado;

update wf_db_autos	 --
   set codcliente = a_cod_correcto
 where codcliente = a_cod_errado;

update wf_ordcomp	 --
   set wf_proveedor = a_cod_correcto
 where wf_proveedor = a_cod_errado;

-- Call Center

select * 
  from caspoliza
 where cod_cliente = a_cod_errado
  into temp tmp_hijo;
 
delete from caspoliza
 where cod_cliente = a_cod_errado;

BEGIN
ON EXCEPTION IN(-268)	   
	delete from cascliente where cod_cliente = a_cod_errado;
END EXCEPTION

	update cascliente
	   set cod_cliente = a_cod_correcto
	 where cod_cliente = a_cod_errado ;
END

update tmp_hijo
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

insert into caspoliza
select * from tmp_hijo;

drop table tmp_hijo;

-- Tabla ponderacion

let _date_changed_corr = null;
let _date_changed_err = null;

select count(*)
  into _cnt_corr
  from ponderacion
 where cod_cliente = a_cod_correcto;

select count(*)
  into _cnt_err
  from ponderacion
 where cod_cliente = a_cod_errado;
 
if _cnt_corr = 0 then
	update ponderacion
	   set cod_cliente = a_cod_correcto
	 where cod_cliente = a_cod_errado;
end if 

if _cnt_corr > 0 and _cnt_err > 0 then
	select date_changed
	  into _date_changed_corr
	  from ponderacion
	 where cod_cliente = a_cod_correcto;

	select date_changed
	  into _date_changed_err
	  from ponderacion
	 where cod_cliente = a_cod_errado; 
	 
	if _date_changed_err > _date_changed_corr then
		delete from ponderacion 
		 where cod_cliente = a_cod_correcto;
		 
		update ponderacion
		   set cod_cliente = a_cod_correcto
		 where cod_cliente = a_cod_errado;
	else
		delete from ponderacion 
		 where cod_cliente = a_cod_errado;
	end if 
end if
--

update recprea1
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

update recprea1
   set cod_reclamante = a_cod_correcto
 where cod_reclamante = a_cod_errado;

--

insert into clidepur(
cod_errado,
cod_correcto,
user_changed,
date_changed
)
values(
a_cod_errado,
a_cod_correcto,
a_user,
_tiempo
);

if a_direccion <> "" then 
	update cliclien
	   set direccion_1 = a_direccion
     where cod_cliente = a_cod_correcto;
end if 

if a_tel <> "" then
	update cliclien
	   set telefono1   = a_tel
	 where cod_cliente = a_cod_correcto;
end if 

if a_nacimiento <> "" then
	update cliclien
	   set fecha_aniversario = a_nacimiento
	 where cod_cliente       = a_cod_correcto;
end if

delete from cliclien
 where cod_cliente = a_cod_errado;

end
 
update clideagr
   set estado     = 1
 where cod_agrupa = a_cod_agrupa;

--commit work;


return 0, "Actualizacion Exitosa";

end procedure

   