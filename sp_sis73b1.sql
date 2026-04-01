-- Depuracion de la tabla de Clientes

-- Creado    : 06/04/2005 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_sis73b;

create procedure "informix".sp_sis73b(
a_cod_errado	char(10), 
a_cod_correcto 	char(10),
a_user		    char(8),
a_cod_agrupa    char(10),
a_direccion	    char(55),
a_tel		    char(12),
a_nacimiento	date

) returning integer,
            char(100);

define _tiempo	datetime year to fraction(5);
define _error	integer;

let _tiempo = current;

--set debug file to "sp_sis73.trc";
--trace on;

--begin work;

begin
on exception set _error
   --	rollback work;
	return _error, "Error al Actualizar el Registro";
end exception

--select estado
-- into _estatus
--  from clideagr
-- where cod_agrupa = a_cod_agrupa;

--if _estatus = 1 then
--	return 1, "Este Registro Ya Fue Procesado";
--end if


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

update cobcapen
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

update cobcatmp
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

update cobcatmp3
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

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

update emidepen
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

update emipomae
   set cod_contratante = a_cod_correcto
 where cod_contratante = a_cod_errado;

update emipomae
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

update emiporen
   set cod_contratante = a_cod_correcto
 where cod_contratante = a_cod_errado;

update emiporen
   set cod_pagador = a_cod_correcto
 where cod_pagador = a_cod_errado;

update emipouni	  --
   set cod_asegurado = a_cod_correcto
 where cod_asegurado = a_cod_errado;

update emiprede	 --
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

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

update recterce	--
   set cod_conductor = a_cod_correcto
 where cod_conductor = a_cod_errado;

update recterce	--
   set cod_tercero = a_cod_correcto
 where cod_tercero = a_cod_errado;

update rectrmae	 ---
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

update rectrmae	 ---
   set cod_proveedor = a_cod_correcto
 where cod_proveedor = a_cod_errado;

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

update cascliente
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

update tmp_hijo
   set cod_cliente = a_cod_correcto
 where cod_cliente = a_cod_errado;

insert into caspoliza
select * from tmp_hijo;

drop table tmp_hijo;

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

commit work;
return 0, "Actualizacion Exitosa";

end procedure



