-- POLIZAS VIGENTES 
--

   DROP procedure sp_jean03;
   CREATE procedure sp_jean03()
   RETURNING char(10);
   
    DEFINE _no_poliza,_no_factura	 	CHAR(10);
    DEFINE _no_documento    CHAR(20);
    DEFINE _cod_agente      CHAR(5);
	define _cod_contratante char(10);
    DEFINE _n_contratante,_n_agente,_n_forma_pago   	CHAR(50);
	define _vi,_vf,_fecha_emision		    date;
	define _cod_formapag	CHAR(3);
	define _pro_cotizacion,_cant  integer;
	define _porc_comision dec(5,2);

--    CALL sp_pro03("001","001",a_fecha,"002;") RETURNING v_filtros;

foreach
	{select cob.no_poliza
	  into _no_poliza
      from cobredet cob
     inner join emipomae emi on emi.no_poliza = cob.no_poliza
     inner join emipoagt agt on agt.no_poliza = emi.no_poliza and agt.porc_comis_agt = 0
     where no_remesa = '1867124'}
	 
	 select emi.no_poliza
	   into _no_poliza
       from emipomae emi
      inner join emipoagt agt on agt.no_poliza = emi.no_poliza
	  where agt.cod_agente = '02904'
	    and agt.porc_comis_agt = 0
	    and emi.estatus_poliza = 1
	
	let _porc_comision = 0.00;
	
	select porc_comis_agt
	  into _porc_comision
	  from emipoagt
	 where no_poliza = _no_poliza;

    if _porc_comision = 0 then
	    update emipoagt
		   set porc_comis_agt = 20
		 where no_poliza = _no_poliza;
        
        update endmoage
           set porc_comis_agt = 20
		 where no_poliza = _no_poliza
		   and no_endoso = '00000';
        		
		return _no_poliza with resume;
	end if	

end foreach
END PROCEDURE;
