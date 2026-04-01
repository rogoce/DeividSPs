--esto se hizo para actualizar unos registros de gisela de ledezma de avisos de cancelacion
--17/07/2007

drop procedure sp_actualizar_aviso;

create procedure "informix".sp_actualizar_aviso()
returning char(20),char(3),integer,integer,date,date,date;

define _no_poliza 		char(10);
define _no_pol	 		char(10);
define _cod_agente      char(5);
define _no_documento    char(20);
define _fecha_aviso     date;
define _cod_leasing     char(10);
define _cod_errado      char(10);
define _cod_leasing1    char(10);
define _cod_errado1     char(10);
define _cnt             integer;								
define _serie,_serie_p  integer;
define li_return        integer;
define _vigencia_inic,_vig_inic,_vig_final   date;
define _cod_ramo        char(3);

let _no_pol = " ";

foreach

	select cod_ramo,
	       vigencia_inic,
		   no_poliza,
		   serie,
		   no_documento
	  into _cod_ramo,
	       _vigencia_inic,
		   _no_poliza,
		   _serie_p,
		   _no_documento
      from emipomae
	 where actualizado = 1
       and fecha_suscripcion between '01/12/2011' and today

	select serie,vig_inic,vig_final
	  into _serie,_vig_inic,_vig_final
	  from rearumae
	 where cod_ramo = _cod_ramo
	   and activo   = 1
	   and _vigencia_inic between vig_inic and vig_final;

	if _serie <> _serie_p then

	   	update emipomae
		   set serie     = _serie
		 where no_poliza = _no_poliza;

	end if

	return _no_documento,_cod_ramo,_serie_p,_serie,_vigencia_inic,_vig_inic,_vig_final with resume; 



end foreach



{foreach

	select no_poliza
	  into _no_poliza
	  from  emifacon
	 where cod_contrato = '00606'
	   and cod_cober_reas = '011'
	 group by 1

    update emireaco
	   set cod_contrato = '00599'
	 where no_poliza    = _no_poliza
       and cod_contrato = '00606'
	   and cod_cober_reas = '011';

    update emifacon
	   set cod_contrato = '00599'
	 where no_poliza    = _no_poliza
       and cod_contrato = '00606'
	   and cod_cober_reas = '011';

{	update emipomae
	   set serie     = 2011
	 where no_poliza = _no_poliza;}

--end foreach

{foreach

	select poliza
	  into _no_documento
	  from b

	update emipomae 
	   set carta_aviso_canc = 0,
	       fecha_aviso_canc = null
	 WHERE no_documento = _no_documento;

end foreach}

{select * 
  from chqrenta4
  into temp prueba;

insert into chqrenta
select * from prueba
;

drop table prueba;

select * 
  from chqrenta5
  into temp prueba;

insert into chqrenta3
select * from prueba
;

drop table prueba; }

{foreach

	select no_poliza
	  into _no_poliza
	  from cobaviso
	where cod_cobrador = "097"
	  and tipo_aviso   = 1
	  and imprimir     = 1
	  and cobra_poliza = "C"
	  and no_documento in("0102-00382-01","0107-00030-01","0208-00991-01","0207-00364-04",
	  					  "0106-00513-01","0104-00178-01","0108-00240-01","1805-00009-04",
	  					  "0194-0644-01","0204-00601-01","0107-00166-01","0108-00222-01",
	  					  "1800-00206-01","0106-00246-01","0106-00185-01","0193-0354-01","0207-01808-01")
	order by nombre_cliente

	update cobaviso
	   set impreso = 1
	 where cod_cobrador = "097"
	   and no_poliza    = _no_poliza;

	update emipomae
	   set carta_aviso_canc = 1,
	       fecha_aviso_canc = "02/10/2008"
	 where no_poliza        = _no_poliza;

--	  and cod_agente   = "00991"
--	  and cod_sucursal = "005"
--end foreach}

{foreach
	select no_poliza,
	       no_documento,
		   vigencia_final
	  into _no_poliza,
	       _no_documento,
		   _vigencia_final
	  from emipomae
	 where fecha_suscripcion between a_fecha and a_fecha2
       and actualizado = 1
       and nueva_renov = "R"
	   and year(vigencia_final) = 2008

	select count(*)
	  into _cnt
	  from emirepol
	 where no_documento = _no_documento;

   if _cnt > 0 then

		foreach
			select no_poliza
			  into _no_pol
			  from emiporen
			 where no_documento = _no_documento
			exit foreach;
		end foreach

		if _no_pol is null then
			let _no_pol = "";
		end if

		return _no_poliza,_no_documento,_no_pol,_vigencia_final with resume;

	   --let li_return = sp_sis61d(_no_pol);
	   --DELETE FROM emirepol WHERE no_documento = _no_documento;

   end if


	{select no_documento
	  into _no_documento
	  from caspoliza

    let _no_poliza = sp_sis21(_no_documento);

	select fecha_aviso_canc
	  into _fecha_aviso
	  from emipomae
	 where actualizado = 1
	   and no_poliza   = _no_poliza;

	if _fecha_aviso = "19/07/2007" then
		update emipomae 
		   set carta_aviso_canc = 0,
		       fecha_aviso_canc = null
		 WHERE no_poliza = _no_poliza;		
	else
		continue foreach;
	end if

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		 exit foreach;
	end foreach

	select cod_cobrador
	  into _cod_cobrador
	  from agtagent
	 where cod_agente = _cod_agente;

	if _cod_cobrador in ("017","018","037","069","079","085","086","090","092") then

		update emipomae 
		   set carta_aviso_canc = 0,
		       fecha_aviso_canc = null
		 WHERE no_poliza = _no_poliza;
	else
		continue foreach;
	end if}

end procedure