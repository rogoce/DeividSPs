-- Procedimiento para insertar en la tabla rearucon el contrato pero con la cobertura 031 Automovil Casco a las rutas del ramo Automovil
-- 
-- Creado    : 03/09/2013 - Autor: Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis109b;		

Create Procedure "informix".sp_sis109b()
RETURNING INTEGER, CHAR(200);
		  	
define _no_endoso        CHAR(5);

DEFINE _cod_contrato	 CHAR(5);
DEFINE _cod_cober_reas   CHAR(3);
DEFINE _tipo_contrato    SMALLINT;
DEFINE _factor_impuesto	 DEC(5,2);
DEFINE _porc_comis_agt	 DEC(5,2);
DEFINE _cantidad,_orden	 INTEGER;
DEFINE _cuenta_cat       CHAR(25);   
DEFINE _cod_coasegur     CHAR(3);
define _cod_ruta         char(5);

define _error_cod,_cnt	 INTEGER;
define _error_isam		 INTEGER;
define _error_desc		 CHAR(200);
DEFINE _contador,li_orden INTEGER;
define _cod_ramo		 char(3);
define _imp_gob 		 smallint;
define _serie   		 smallint;
define _desc_cont		 char(50);
define _desc_cob         char(50);
define _tiene_comision	 smallint;
define _null			 char(1);
define _suma			 dec(16,2);

define _pbs_endoso		 dec(16,2);
define _pbs_historico	 dec(16,2);
define _no_factura		 char(10);

define _traspaso		 smallint;
define _cod_traspaso	 char(5);
define _no_unidad        char(5);
define _cod_cober_reas_o  char(3);

Set Isolation To Dirty Read;

let _contador = 0.00;
let _null     = null;
let _no_endoso = '00000';

begin 
on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_desc;
end exception

Foreach

 Select cod_ruta,cod_ramo
   Into _cod_ruta,_cod_ramo
   From rearumae
  order by cod_ramo,serie

   select *	from rearucon
	where cod_ruta = _cod_ruta
	 into temp temp_rea_pr;

  Foreach

		select cod_cober_reas
		  into _cod_cober_reas
		  from reacobre
		 where cod_ramo = _cod_ramo

        select count(*)
		  into _cnt
          from prdcober
         where cod_ramo = _cod_ramo
           and cod_cober_reas = _cod_cober_reas;

        if _cnt = 0 then
			continue foreach;
		end if

		let _cod_cober_reas_o = null;

		Foreach
		   select cod_contrato,
		          orden,
				  cod_cober_reas
		     into _cod_contrato,
			      _orden,
				  _cod_cober_reas_o
			 from temp_rea_pr
			where cod_ruta = _cod_ruta
			order by orden

		  if _cod_cober_reas_o is null then

		      update rearucon
			     set cod_cober_reas = _cod_cober_reas
			   where cod_ruta       = _cod_ruta
			     and orden          = _orden
			     and cod_contrato   = _cod_contrato;

		      update temp_rea_pr
			     set cod_cober_reas = _cod_cober_reas
			   where cod_ruta       = _cod_ruta
			     and orden          = _orden
			     and cod_contrato   = _cod_contrato;

		  else

			   select count(*)
			     into _cnt
				 from rearucon
				where cod_ruta       = _cod_ruta
				  and orden          = _orden
				  and cod_contrato   = _cod_contrato
				  and cod_cober_reas = _cod_cober_reas;

			   if _cnt > 0 then
			   else
					select * from rearucon
					 where cod_contrato   = _cod_contrato
				       and orden          = _orden
					   and cod_ruta       = _cod_ruta
				      into temp prueba;

					let li_orden = 0;

					select max(orden) + 1
					  into li_orden
					  from rearucon
					 where cod_ruta = _cod_ruta;

					update prueba
					   set cod_cober_reas = _cod_cober_reas,
					       orden          = li_orden;

					delete from prueba
					where orden <> li_orden;

					insert into rearucon
					select * 
					  from prueba;

					drop table prueba;

			   end if
		  end if
	    End foreach

  End Foreach
	drop table temp_rea_pr;
End Foreach

end

let _error_cod  = 0;
let _error_desc = "Proceso Completado.";	

return _error_cod, _error_desc;

End Procedure;
