-- Procedure para crear una transaccion de reclamos que anula a otra

-- Creado    : 05/05/2004 - Autor: Demetrio Hurtado Almanza 

--drop procedure sp_rec87;

create procedure "informix".sp_rec87(a_transaccion char(10))

define _periodo	char(7);

let _periodo = sp_sis39(today);

select *
  from rectrmae
 where transaccion = a_transaccion
  into temp temp_anular

update temp_anular
   set transaccion    = null,
       no_requis      = null,
	   no_remesa      = null,
	   renglon        = null,
	   fecha          = today,
	   impreso        = 0,
	   perd_total     = 0,
	   cerrar_rec     = 0,
	   no_impresion   = 0,
	   periodo        = _periodo,
	   pagado         = 0,
	   monto          = monto * -1,
	   variacion      = 0.00,
	   generar_cheque = 0,
	   actualizado    = 0,



       


insert into prdprod
select *
  from tmp_temp;

drop table tmp_temp;

end procedure