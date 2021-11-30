class ItemBarril{
  int id;
  String nome;
  String nomeImage;
  String slot;
  String nomeSlot;
  int preco;
  int quantidade;
  int slot0;
  int slot1;
  int slot2;
  int slot3;
  int refinamento;
  int optionAmount;
  int option0;
  int option1;
  int option2;
  int option3;
  int option4;
  int optionValue0;
  int optionValue1;
  int optionValue2;
  int optionValue3;
  int optionValue4;
  bool isForged;

  ItemBarril(int id, String nome, String nomeImage, String slot){
    this.id= id;
    this.nome= nome;
    this.nomeImage= nomeImage;
    this.slot= slot;
    this.refinamento=0;
    slot0=0;
    slot1=0;
    slot2=0;
    slot3=0;
    option0=0;
    option1=0;
    option2=0;
    option3=0;
    option4=0;
    optionValue0=0;
    optionValue1=0;
    optionValue2=0;
    optionValue3=0;
    optionValue4=0;
    isForged=false;
    setNomeSlot(this.nome, this.slot);
  }

  int getId(){
    return this.id;
  }

  String getNome(){
    return this.nome;
  }

  String getNomeImage(){
    return this.nomeImage;
  }

  String getSlot(){
    return this.slot;
  }

  String getNomeSlot(){
    return this.nomeSlot;
  }

  int getPreco(){
    return this.preco;
  }

  int getQuantidade(){
    return this.quantidade;
  }

  int getSlot0(){
    return this.slot0;
  }

  int getSlot1(){
    return this.slot1;
  }

  int getSlot2(){
    return this.slot2;
  }

  int getSlot3(){
    return this.slot3;
  }

  int getRefinamento(){
    return this.refinamento;
  }

  int getOption0(){
    return this.option0;
  }
  
    int getOption1(){
    return this.option1;
  }
  
    int getOption2(){
    return this.option2;
  }

    int getOption3(){
    return this.option3;
  }

    int getOption4(){
    return this.option4;
  }

    int getOptionValue0(){
    return this.optionValue0;
  }

      int getOptionValue1(){
    return this.optionValue1;
  }

      int getOptionValue2(){
    return this.optionValue2;
  }

      int getOptionValue3(){
    return this.optionValue3;
  }

      int getOptionValue4(){
    return this.optionValue4;
  }

      int getOptionAmount(){
        return this.optionAmount;
      }
  
  bool getForgeStatus(){
    return this.isForged;
  }

  void setNomeSlot(String nome, String slot){
    String noBracket= slot.substring(1,2);
    if(int.parse(noBracket)==0)
      this.nomeSlot= nome;
    else
      if(slot.endsWith(')'))
        this.nomeSlot= nome+' '+slot.substring(0,3);
      else
        this.nomeSlot= nome+' '+slot;

    if(this.slot0 >= 4750 && this.slot0 <= 4792){//Item tem modificador (Item foi forjado e não tem slot de carta)
      this.nomeSlot= nome;
      this.isForged= true;
    }
    if(this.refinamento>0){
      this.nomeSlot= '+'+this.refinamento.toString()+' '+this.nomeSlot;
    }

  }

  void setPreco(int preco){
    this.preco=preco;
  }
  
  void setQuantidade(int quantidade){
    this.quantidade=quantidade;
  }

    void setSlot0(int id){
    this.slot0= id;
  }

    void setSlot1(int id){
    this.slot1= id;
  }

    void setSlot2(int id){
    this.slot2= id;
  }

    void setSlot3(int id){
    this.slot3= id;
  }

    void setOption0(int id){
      this.option0= id;
    }

    void setOption1(int id){
      this.option1= id;
    }

    void setOption2(int id){
      this.option2= id;
    }

    void setOption3(int id){
      this.option3= id;
    }

    void setOption4(int id){
      this.option4= id;
    }

    void setOptionValue0(int id){
      this.optionValue0= id;
    }

    void setOptionValue1(int id){
      this.optionValue1= id;
    }

    void setOptionValue2(int id){
      this.optionValue2= id;
    }

    void setOptionValue3(int id){
      this.optionValue3= id;
    }

    void setOptionValue4(int id){
      this.optionValue4= id;
    }

    void setOptionAmount(){
      int count=0;
      if(option0!=0)
        count++;
      if(option1!=0)
        count++;
      if(option2!=0)
        count++;
      if(option3!=0)
        count++;
      if(option4!=0)
        count++;

      this.optionAmount= count;
    }

  void setRefinamento(int refino){
    this.refinamento= refino;
    setNomeSlot(this.nome, this.slot);
  }




}