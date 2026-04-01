drop procedure pd_emipomae;
create procedure "informix".pd_emipomae(old_no_poliza char(10))
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

--set debug file to "pd_emipomae.trc";
--trace on;

    --  Delete all children in "emipouni"
    delete from emipouni
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emipoagt"
    delete from emipoagt
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emidirco"
    delete from emidirco
    where  no_poliza = old_no_poliza;

    --  Delete all children in "endasien"
    delete from endasien
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emiciara"
    delete from emiciara
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emicoama"
    delete from emicoama
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emicoami"
    delete from emicoami
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emihcmm"
    delete from emihcmm
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emipolde"
    delete from emipolde
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emiporec"
    delete from emiporec
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emipolim"
    delete from emipolim
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emigloco"
    delete from emigloco
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emireagm"
    delete from emireagm
    where  no_poliza = old_no_poliza;

    --  Delete all children in "eminotas"
    delete from eminotas
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emifafac"
    delete from emifafac
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emifacon"
    delete from emifacon
    where  no_poliza = old_no_poliza;

end procedure                                                                                                                                                                                                                                                      
