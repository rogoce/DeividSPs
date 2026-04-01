-- Simulacion de cambio de contrato de reaseguro
-- Crear registros Nuevos a partir de los anteriores

-- SIS v.2.0 - DEIVID, S.A.
-- Creado    : 07/08/2012 - Autor: Armando Moreno

--execute procedure sp_sim001('00616','00613',2)


--DROP procedure sp_sim001;

CREATE procedure sp_sim001(
a_cod_cont_nvo CHAR(05),
a_cod_cont_ant CHAR(05),
a_tipo         smallint default 1
) RETURNING    integer,char(100);


define _no_poliza char(10);
define _no_endoso char(5);
define _no_remesa char(10);
define _renglon   integer;

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);
define _porc_partic_prima_a    decimal(9,6);
define _porc_partic_prima_n,_porc_prima_ret    decimal(9,6);
define _serie_ant,_serie_nvo   integer;
define _cod_ramo    char(3);
define _prima_neta	decimal(16,2);
define _no_unidad   char(5);
define _no_tranrec,_no_reclamo  char(10);
define _cod_ruta,_contrato_ret  char(5);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception


delete from semifacon;
delete from scobreaco;
delete from srectrrea;

--SET DEBUG FILE TO "sp_sim001.trc";
--TRACE ON;                                                                


select serie into _serie_ant from reacomae
where cod_contrato = a_cod_cont_ant;

select serie into _serie_nvo from reacomae
where cod_contrato = a_cod_cont_nvo;

foreach

		select no_poliza,
		       no_endoso,
			   no_unidad
		  into _no_poliza,
		       _no_endoso,
			   _no_unidad
		  from emifacon
		 where cod_contrato = a_cod_cont_ant
	  group by 1,2,3
	  order by 1,2,3

	  select cod_ramo into _cod_ramo from emipomae
	   where no_poliza = _no_poliza;

	  select t.porc_partic_prima
	    into _porc_partic_prima_a
	    from rearumae r, rearucon t
	   where r.cod_ruta = t.cod_ruta
	     and t.cod_contrato = a_cod_cont_ant
	     and r.serie        = _serie_ant
	     and r.cod_ramo     = _cod_ramo;

	  select t.porc_partic_prima,t.cod_ruta
	    into _porc_partic_prima_n,_cod_ruta
	    from rearumae r, rearucon t
	   where r.cod_ruta = t.cod_ruta
	     and t.cod_contrato = a_cod_cont_nvo
	     and r.serie        = _serie_nvo
	     and r.cod_ramo     = _cod_ramo;

	  foreach
		  select cod_contrato,porc_partic_prima
		    into _contrato_ret,_porc_prima_ret
		    from rearucon
		   where cod_ruta = _cod_ruta
			 and porc_partic_prima <> 0
			 and cod_contrato <> a_cod_cont_nvo
		   exit foreach;
	  end foreach

	    select * 
	      from emifacon
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad
		  into temp prueba;

		if _porc_partic_prima_a <> _porc_partic_prima_n then

	        foreach
			  select prima_neta
			    into _prima_neta
				from endeduni
			   where no_poliza = _no_poliza
			     and no_endoso = _no_endoso
				 and no_unidad = _no_unidad

			  update prueba
			     set prima             = _prima_neta * _porc_partic_prima_n /100,
				     porc_partic_prima = _porc_partic_prima_n
			   where cod_contrato      = a_cod_cont_ant
			     and no_poliza = _no_poliza
				 and no_endoso = _no_endoso
				 and no_unidad = _no_unidad;

			  update prueba
			     set prima             = _prima_neta * _porc_prima_ret / 100,     --((100 - _porc_partic_prima_n) /100),
				     porc_partic_prima = _porc_prima_ret, --(100 - _porc_partic_prima_n)
				     cod_contrato      = _contrato_ret	
			   where cod_contrato      <> a_cod_cont_ant
			     and no_poliza = _no_poliza
				 and no_endoso = _no_endoso
				 and no_unidad = _no_unidad;

			end foreach

			update prueba
			   set cod_contrato = a_cod_cont_nvo
			 where cod_contrato = a_cod_cont_ant;

			insert into semifacon
			select * from prueba;

		    drop table prueba;
		else
			update prueba
			   set cod_contrato = a_cod_cont_nvo
			 where cod_contrato = a_cod_cont_ant;

			insert into semifacon
			select * from prueba;

		    drop table prueba;

		end if

	return 1,'' with resume;
end foreach	 

--elif a_tipo = 2 then --Cobros

	FOREACH 
	     SELECT cobredet.no_remesa,cobredet.renglon,cobredet.no_poliza
	       INTO _no_remesa,_renglon,_no_poliza
	       FROM cobredet, cobreaco c
		  WHERE cobredet.no_remesa = c.no_remesa
	        and cobredet.renglon   = c.renglon
	        and cobredet.actualizado = 1
			and cobredet.tipo_mov    in ("P", "N")
		    and c.cod_contrato       = a_cod_cont_ant
		  order by cobredet.no_remesa

		 select cod_ramo into _cod_ramo from emipomae
		  where no_poliza = _no_poliza;

	     select * 
	       from cobreaco
		  where no_remesa = _no_remesa
		    and renglon   = _renglon
		   into temp prueba;

		  select t.porc_partic_prima
		    into _porc_partic_prima_a
		    from rearumae r, rearucon t
		   where r.cod_ruta = t.cod_ruta
		     and t.cod_contrato = a_cod_cont_ant
		     and r.serie        = _serie_ant
		     and r.cod_ramo     = _cod_ramo;

		  select t.porc_partic_prima,t.cod_ruta
		    into _porc_partic_prima_n,_cod_ruta
		    from rearumae r, rearucon t
		   where r.cod_ruta = t.cod_ruta
		     and t.cod_contrato = a_cod_cont_nvo
		     and r.serie        = _serie_nvo
		     and r.cod_ramo     = _cod_ramo;

		  foreach
			  select cod_contrato,porc_partic_prima
			    into _contrato_ret,_porc_prima_ret
			    from rearucon
			   where cod_ruta = _cod_ruta
				 and porc_partic_prima <> 0
				 and cod_contrato <> a_cod_cont_nvo
			   exit foreach;
		  end foreach


     	  if _porc_partic_prima_a <> _porc_partic_prima_n then
			  update prueba
			     set porc_partic_prima = _porc_partic_prima_n
			   where cod_contrato      = a_cod_cont_ant;

			  update prueba
			     set porc_partic_prima = _porc_prima_ret,
			         cod_contrato      = _contrato_ret		--(100 - _porc_partic_prima_n)
			   where cod_contrato      <> a_cod_cont_ant;

		  end if

		 update prueba
		    set cod_contrato = a_cod_cont_nvo
		  where cod_contrato = a_cod_cont_ant;

		 insert into scobreaco
		 select * from prueba;

	     drop table prueba;

		return 1,'' with resume;

	END FOREACH

--elif a_tipo = 3 then --Reclamos

foreach

	select no_tranrec
	  into _no_tranrec
	  from rectrrea
	 where cod_contrato = a_cod_cont_ant

   select *
	 from rectrrea
    where no_tranrec = _no_tranrec
     into temp prueba;

       select no_reclamo into _no_reclamo from rectrmae
	   where no_tranrec = _no_tranrec;

	   select no_poliza into _no_poliza from recrcmae
	   where no_reclamo = _no_reclamo;

	   select cod_ramo into _cod_ramo from emipomae
	    where no_poliza = _no_poliza;

	  select t.porc_partic_prima
	    into _porc_partic_prima_a
	    from rearumae r, rearucon t
	   where r.cod_ruta = t.cod_ruta
	     and t.cod_contrato = a_cod_cont_ant
	     and r.serie        = _serie_ant
	     and r.cod_ramo     = _cod_ramo;

	  select t.porc_partic_prima,t.cod_ruta
	    into _porc_partic_prima_n,_cod_ruta
	    from rearumae r, rearucon t
	   where r.cod_ruta = t.cod_ruta
	     and t.cod_contrato = a_cod_cont_nvo
	     and r.serie        = _serie_nvo
	     and r.cod_ramo     = _cod_ramo;

	  foreach
		  select cod_contrato,porc_partic_prima
		    into _contrato_ret,_porc_prima_ret
		    from rearucon
		   where cod_ruta = _cod_ruta
			 and porc_partic_prima <> 0
			 and cod_contrato <> a_cod_cont_nvo
		   exit foreach;
	  end foreach

   	  if _porc_partic_prima_a <> _porc_partic_prima_n then
			  update prueba
			     set porc_partic_prima = _porc_partic_prima_n
			   where cod_contrato      = a_cod_cont_ant;

			  update prueba
			     set porc_partic_prima = _porc_prima_ret,		--(100 - _porc_partic_prima_n)
					 cod_contrato      = _contrato_ret
			   where cod_contrato      <> a_cod_cont_ant;

	  end if
	
	 update prueba
	    set cod_contrato = a_cod_cont_nvo
	  where cod_contrato = a_cod_cont_ant;

	 insert into srectrrea
	 select * from prueba;

	 drop table prueba;

end foreach

--End If

end

let _error  = 0;
let _error_desc = "Proceso Completado ...";	

return _error, _error_desc;
   
END PROCEDURE;
