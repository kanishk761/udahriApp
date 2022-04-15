class min_transactions:
    def __init__(self, udhars, udhar_givers):
        self.udhars = udhars
        self.udhar_givers = udhar_givers

        self.n = len(udhars)
        self.m = len(udhar_givers)
        
        self.udhar_participants = [ [] for _ in range(self.n) ]
        self.udhar_groups = [-1]*self.n

        possibles = pow(2, self.m)
        self.memP = [[[False for k in range(possibles)] for j in range(self.m)] for i in range(self.n)]
        self.mem = [[[0 for k in range(possibles)] for j in range(self.m)] for i in range(self.n)]
        self.path = [[[-1 for k in range(possibles)] for j in range(self.m)] for i in range(self.n)]

        self.min_transactions = self.m+self.n

        self.final_create_udhar_taker_groups = []
        self.final_create_udhar_giver_groups = []


    #udhar_givers = [95]
    #udhars = [15, 5, 25, 15, 10, 5, 20]

    #n = len(udhars)
    #m = len(udhar_givers)


    #udhar_participants = [ [] for _ in range(n) ]

    #udhar_groups = [-1]*n
    #min_transactions = m+n
    def get_transactions(self):
        self.create_udhar_groups(0,0)

    def create_udhar_groups(self, i, limit):
        
        if i == len(self.udhars):
            
            visited = [False] *len(self.udhar_givers)
            x = self.satisfy_udhar_groups(0, 0, visited)

            if x <  self.min_transactions:
                self.final_create_udhar_giver_groups = self.create_udhar_giver_groups()

                self.final_create_udhar_taker_groups.clear()
                for i in range(len(self.udhar_participants)):
                    temp = []
                    for j in range(len(self.udhar_participants[i])):
                        temp.append(self.udhar_participants[i][j])
                    self.final_create_udhar_taker_groups.append(temp)
                
                self.min_transactions = x
            return

        for j in range(limit):
            self.udhar_groups[j] += self.udhars[i]
            self.udhar_participants[j].append(i)

            self.create_udhar_groups(i+1, limit)

            self.udhar_groups[j] -= self.udhars[i]
            self.udhar_participants[j].pop()

        self.udhar_participants[limit].append(i)
        self.udhar_groups[limit] = self.udhars[i]

        self.create_udhar_groups(i+1, limit+1)
        self.udhar_participants[limit].pop()
        self.udhar_groups[limit] = -1

    def satisfy_udhar_groups(self, i, j, visited):
        if  i == len(self.udhar_groups) or self.udhar_groups[i] == -1:
            return 0

        if j == len(self.udhar_givers):
            if self.udhar_groups[i] == 0:
                m = len(self.udhar_participants[i])
                return m + self.satisfy_udhar_groups(i+1, 0, visited) - 1
            else:
                return 999999 #inf
        num_visited = self.to_num(visited)
        if self.memP[i][j][num_visited]:
            return self.mem[i][j][num_visited]
        
        leave = self.satisfy_udhar_groups(i, j+1, visited)
        if not visited[j]:
            visited[j] = True
            self.udhar_groups[i] -= self.udhar_givers[j]

            take = 1 + self.satisfy_udhar_groups(i, j+1, visited)

            visited[j] = False
            self.udhar_groups[i] += self.udhar_givers[j]
            if leave < take:
                self.path[i][j][num_visited] = 0
            else:
                self.path[i][j][num_visited] = 1
            
            self.mem[i][j][num_visited] = min(leave, take)
            return min(leave, take)

        self.path[i][j][num_visited] = 0
        self.mem[i][j][num_visited] = leave
        return leave

    def create_udhar_giver_groups(self):
        visited = [False]*len(self.udhar_givers)  
        udhar_giver_participants = [ [] for _ in range(self.n) ]
        for i in range(len(self.udhar_groups)):
            for j in range(len(self.udhar_givers)):
                if self.path[i][j][self.to_num(visited)] == 1:
                    visited[j] = True
                    udhar_giver_participants[i].append(j)
        return udhar_giver_participants
    
    def to_num(self, visited):
        num = 0
        cur = 1
        for i in visited:
            if i:
                num = num + cur
            cur = cur*2
        return num